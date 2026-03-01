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
        bridge = "mk_bridge",
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
        bridge = "mk_bridge",
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
        return PrintErr(Err("", "INVALID_ARGS", "Falta comando (health|catalog|search|item)."), 2);

    var cmd = args[0].ToLowerInvariant();
    var requestId = ArgValue(args, "--request-id");

    switch (cmd)
    {
        case "health":
            return PrintOk(Ok(requestId, new { status = "ok" }));

        case "catalog":
            // Stub: catalogo fake para validar integracion con Flutter.
            var catalog = new[]
            {
                new { code="380104", name="FLUOXETINA 20 MG COMPRIMIDOS (PET. MINIMO)", source="FARMACIA" },
                new { code="502602", name="KIT RADIOFRECUENCIA HECA (ELECTRODOS 15 CM)", source="BODEGA" },
            };
            return PrintOk(Ok(requestId, catalog));

        case "search":
            var q = ArgValue(args, "--q");
            var all = new[]
            {
                new { code="380104", name="FLUOXETINA 20 MG COMPRIMIDOS (PET. MINIMO)", source="FARMACIA" },
                new { code="502602", name="KIT RADIOFRECUENCIA HECA (ELECTRODOS 15 CM)", source="BODEGA" },
            };

            var filtered = string.IsNullOrWhiteSpace(q)
                ? all
                : all.Where(x =>
                        x.name.Contains(q, StringComparison.OrdinalIgnoreCase)
                        || x.code.Contains(q, StringComparison.OrdinalIgnoreCase))
                    .ToArray();

            return PrintOk(Ok(requestId, filtered));

        case "item":
            var code = ArgValue(args, "--code");
            if (string.IsNullOrWhiteSpace(code))
                return PrintErr(Err(requestId, "INVALID_ARGS", "Falta --code."), 2);

            if (code == "380104")
                return PrintOk(Ok(requestId, new { code = "380104", name = "FLUOXETINA 20 MG COMPRIMIDOS (PET. MINIMO)", source = "FARMACIA" }));

            return PrintErr(Err(requestId, "NOT_FOUND", $"No existe item con code={code}."), 11);

        default:
            return PrintErr(Err(requestId, "INVALID_ARGS", $"Comando desconocido: {cmd}."), 2);
    }
}
catch (Exception ex)
{
    var requestId = ArgValue(args, "--request-id");
    return PrintErr(Err(requestId, "UNEXPECTED_ERROR", "Fallo inesperado.", ex.ToString()), 90);
}