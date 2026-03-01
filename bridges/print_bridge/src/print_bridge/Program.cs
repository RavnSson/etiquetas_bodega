using System.Text.Json;

static string ArgValue(string[] args, string key)
{
    var idx = Array.IndexOf(args, key);
    if (idx >= 0 && idx + 1 < args.Length) return args[idx + 1];
    return "";
}

static object Ok(string requestId, object data) => new
{
    ok = true,
    meta = new
    {
        bridge = "print_bridge",
        version = "1.0.0",
        ts = DateTime.UtcNow.ToString("O"),
        requestId = requestId
    },
    data = data
};

static object Err(string requestId, string code, string message, string? details = null) => new
{
    ok = false,
    meta = new
    {
        bridge = "print_bridge",
        version = "1.0.0",
        ts = DateTime.UtcNow.ToString("O"),
        requestId = requestId
    },
    error = new { code, message, details }
};

static int PrintOk(object payload)
{
    Console.WriteLine(JsonSerializer.Serialize(payload));
    return 0;
}

static int PrintErr(object payload, int exitCode)
{
    Console.WriteLine(JsonSerializer.Serialize(payload));
    return exitCode;
}

try
{
    if (args.Length == 0)
        return PrintErr(Err("", "INVALID_ARGS", "Falta comando (health|print)."), 2);

    var cmd = args[0].ToLowerInvariant();
    var requestId = ArgValue(args, "--request-id");

    switch (cmd)
    {
        case "health":
            return PrintOk(Ok(requestId, new { status = "ok" }));

        case "print":
            var code = ArgValue(args, "--code");
            var name = ArgValue(args, "--name");
            var copiesStr = ArgValue(args, "--copies");

            if (string.IsNullOrWhiteSpace(code) || string.IsNullOrWhiteSpace(name))
                return PrintErr(Err(requestId, "INVALID_ARGS", "Falta --code o --name."), 2);

            if (!int.TryParse(copiesStr, out var copies)) copies = 1;
            if (copies <= 0) copies = 1;

            // STUB: Por ahora NO imprime. Solo confirma que "imprimio".
            // Aqui despues se integrara RawPrinter / ZPL real.
            return PrintOk(Ok(requestId, new { printed = true, copies = copies }));

        default:
            return PrintErr(Err(requestId, "INVALID_ARGS", $"Comando desconocido: {cmd}."), 2);
    }
}
catch (Exception ex)
{
    var requestId = ArgValue(args, "--request-id");
    return PrintErr(Err(requestId, "UNEXPECTED_ERROR", "Fallo inesperado.", ex.ToString()), 90);
}