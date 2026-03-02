using System;
using System.Linq;
using System.Text.Json;

namespace PrintBridge
{
    internal static class Program
    {
        private static readonly JsonSerializerOptions JsonOpts = new JsonSerializerOptions
        {
            WriteIndented = false
        };

        public static int Main(string[] args)
        {
            // Comandos:
            // health
            // print --code "..." --name "..." --copies 1 [--printer "..."] [--request-id "..."] [--test] [--out "file.zpl"]

            string requestId = GetArg(args, "--request-id") ?? Guid.NewGuid().ToString("N");
            string cmd = args.FirstOrDefault()?.Trim().ToLowerInvariant() ?? "";

            try
            {
                if (cmd == "health")
                    return Ok(requestId, new HealthData());

                if (cmd == "print")
                    return HandlePrint(requestId, args.Skip(1).ToArray());

                return Fail(requestId, "INVALID_ARGS",
                    "Comando inválido. Usa: health | print",
                    $"cmd='{cmd}'");
            }
            catch (Exception ex)
            {
                return Fail(requestId, "UNHANDLED_EXCEPTION", "Error inesperado", ex.ToString());
            }
        }

        private static int HandlePrint(string requestId, string[] args)
        {
            string? code = GetArg(args, "--code");
            string? name = GetArg(args, "--name");
            string? printer = GetArg(args, "--printer");
            bool test = HasFlag(args, "--test");
            string? outPath = GetArg(args, "--out");

            int copies = 1;
            var copiesRaw = GetArg(args, "--copies");
            if (!string.IsNullOrWhiteSpace(copiesRaw) && (!int.TryParse(copiesRaw, out copies) || copies < 1 || copies > 999))
                return Fail(requestId, "INVALID_ARGS", "--copies debe ser 1..999", $"copies='{copiesRaw}'");

            if (string.IsNullOrWhiteSpace(code))
                return Fail(requestId, "INVALID_ARGS", "Falta --code", "");
            if (string.IsNullOrWhiteSpace(name))
                return Fail(requestId, "INVALID_ARGS", "Falta --name", "");

            // Config best-effort
            var cfg = ConfigLoader.LoadBestEffort();

            // Defaults ZPL
            int widthDots = cfg.WidthDots ?? 400;
            int heightDots = cfg.HeightDots ?? 200;

            var zpl = new ZplBuilder(widthDots, heightDots).Build(code!, name!);

            // Guardar ZPL si pidieron --out (sirve incluso en test)
            if (!string.IsNullOrWhiteSpace(outPath))
            {
                try
                {
                    System.IO.File.WriteAllText(outPath!, zpl);
                }
                catch (Exception ex)
                {
                    return Fail(requestId, "IO_ERROR", "No se pudo escribir el archivo --out", ex.ToString());
                }
            }

            // Resolver impresora: CLI > config
            printer ??= cfg.PrinterName;

            // Si NO es test, exigimos impresora
            if (!test && string.IsNullOrWhiteSpace(printer))
            {
                return Fail(
                    requestId,
                    "PRINTER_NOT_FOUND",
                    "No se indicó impresora. Usa --printer o define <printer> en config.xml",
                    "printer is null/empty"
                );
            }

            int totalBytesSent = 0;

            if (!test)
            {
                try
                {
                    for (int i = 0; i < copies; i++)
                    {
                        int written = RawPrinter.SendStringToPrinter(printer!, zpl, docName: $"ZPL {code}");
                        totalBytesSent += written;
                    }
                }
                catch (Exception ex)
                {
                    return Fail(requestId, "SPOOLER_ERROR", "Fallo al enviar a la impresora (RAW)", ex.ToString());
                }
            }

            var data = new PrintData
            {
                Printer = printer ?? "",
                Copies = copies,
                BytesSent = test ? 0 : totalBytesSent,
                TestMode = test,
                ZplPreview = test ? zpl : null,
                OutPath = !string.IsNullOrWhiteSpace(outPath) ? outPath : null
            };

            return Ok(requestId, data);
        }

        private static int Ok<T>(string requestId, T data)
        {
            var res = new BridgeResponse<T>
            {
                Ok = true,
                Meta = new BridgeMeta { RequestId = requestId },
                Data = data
            };

            Console.WriteLine(JsonSerializer.Serialize(res, JsonOpts));
            return 0;
        }

        private static int Fail(string requestId, string code, string message, string details)
        {
            var res = new BridgeResponse<object>
            {
                Ok = false,
                Meta = new BridgeMeta { RequestId = requestId },
                Error = new BridgeError
                {
                    Code = code,
                    Message = message,
                    Details = details ?? ""
                }
            };

            Console.WriteLine(JsonSerializer.Serialize(res, JsonOpts));
            return 1;
        }

        private static string? GetArg(string[] args, string key)
        {
            for (int i = 0; i < args.Length; i++)
            {
                if (!string.Equals(args[i], key, StringComparison.OrdinalIgnoreCase))
                    continue;

                if (i + 1 >= args.Length)
                    return null;

                return args[i + 1];
            }
            return null;
        }

        private static bool HasFlag(string[] args, string flag)
            => args.Any(a => string.Equals(a, flag, StringComparison.OrdinalIgnoreCase));
    }
}