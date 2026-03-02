using System;
using System.IO;
using System.Xml;

namespace PrintBridge
{
    internal sealed class PrintBridgeConfig
    {
        public string? PrinterName { get; set; }
        public int? WidthDots { get; set; }
        public int? HeightDots { get; set; }
    }

    internal static class ConfigLoader
    {
        public static PrintBridgeConfig LoadBestEffort()
        {
            // Búsqueda best-effort en rutas típicas.
            // En release, lo ideal es poner config/config.xml al lado del exe.
            var candidates = new[]
            {
                Path.Combine(Environment.CurrentDirectory, "config", "config.xml"),
                Path.Combine(Environment.CurrentDirectory, "..", "config", "config.xml"),
                Path.Combine(Environment.CurrentDirectory, "..", "..", "config", "config.xml"),
                Path.Combine(Environment.CurrentDirectory, "..", "..", "..", "bridges", "print_bridge", "config", "config.xml"),
            };

            foreach (var path in candidates)
            {
                try
                {
                    if (!File.Exists(path)) continue;
                    return LoadFrom(path);
                }
                catch
                {
                    // ignorar y seguir buscando
                }
            }

            return new PrintBridgeConfig();
        }

        private static PrintBridgeConfig LoadFrom(string path)
        {
            var doc = new XmlDocument();
            doc.Load(path);

            string? Get(string tag)
            {
                var node = doc.SelectSingleNode($"/parametros/{tag}");
                return node?.InnerText?.Trim();
            }

            var cfg = new PrintBridgeConfig();

            var printer = Get("printer");
            if (!string.IsNullOrWhiteSpace(printer))
                cfg.PrinterName = printer;

            if (int.TryParse(Get("widthDots"), out var w))
                cfg.WidthDots = w;

            if (int.TryParse(Get("heightDots"), out var h))
                cfg.HeightDots = h;

            return cfg;
        }
    }
}