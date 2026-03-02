using System.Text.Json;
using System.Xml.Linq;
using Microsoft.Data.SqlClient;

static string ArgValue(string[] args, string key)
{
    var idx = Array.IndexOf(args, key);
    if (idx >= 0 && idx + 1 < args.Length) return args[idx + 1];
    return "";
}

static bool HasFlag(string[] args, string flag) =>
    args.Any(a => string.Equals(a, flag, StringComparison.OrdinalIgnoreCase));

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

// Busca config.xml en ubicaciones típicas (dev y release).
static string FindConfigPath()
{
    var cwd = Directory.GetCurrentDirectory();

    var candidates = new[]
    {
        // Release: si copias config junto al exe (por ejemplo dist/config/config.xml)
        Path.Combine(cwd, "config", "config.xml"),

        // Dev: ejecutando desde bridges/mk_bridge/dist
        Path.GetFullPath(Path.Combine(cwd, "..", "config", "config.xml")),
        Path.GetFullPath(Path.Combine(cwd, "..", "..", "config", "config.xml")),

        // Dev: ejecutando desde apps/flutter_app/etiquetas_bodega (subir al repo root)
        Path.GetFullPath(Path.Combine(cwd, "..", "..", "..", "bridges", "mk_bridge", "config", "config.xml")),

        // Si ejecutas desde root del repo
        Path.GetFullPath(Path.Combine(cwd, "bridges", "mk_bridge", "config", "config.xml")),
    };

    foreach (var p in candidates.Distinct())
    {
        if (File.Exists(p)) return p;
    }

    throw new FileNotFoundException("config.xml no encontrado. Se esperaba en bridges/mk_bridge/config/config.xml o ./config/config.xml");
}

// Carga XML del formato de la foto:
// <parametros><ip>...</ip><mdb>...</mdb><sql>...</sql></parametros>
static (string connectionString, string sqlQuery) LoadConfig(string configPath)
{
    var doc = XDocument.Load(configPath);
    var root = doc.Root;
    if (root is null) throw new Exception("config.xml inválido: sin root.");

    var ip = root.Element("ip")?.Value?.Trim();
    var db = root.Element("mdb")?.Value?.Trim();
    var sql = root.Element("sql")?.Value;

    if (string.IsNullOrWhiteSpace(ip) || string.IsNullOrWhiteSpace(db))
        throw new Exception("config.xml inválido: faltan <ip> o <mdb>.");

    if (string.IsNullOrWhiteSpace(sql))
        throw new Exception("config.xml inválido: falta <sql>.");

    // Auth por defecto: Windows (Integrated Security)
    // Encrypt=false para evitar problemas de certificado en redes internas.
    var csb = new SqlConnectionStringBuilder
    {
        DataSource = ip,
        InitialCatalog = db,
        IntegratedSecurity = true,
        Encrypt = false,
        TrustServerCertificate = true,
        ConnectTimeout = 10
    };

    return (csb.ToString(), sql);
}

static List<Dictionary<string, object?>> ReadRows(SqlCommand cmd)
{
    using var rd = cmd.ExecuteReader();
    var rows = new List<Dictionary<string, object?>>();

    while (rd.Read())
    {
        var row = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        for (int i = 0; i < rd.FieldCount; i++)
        {
            var name = rd.GetName(i);
            var val = rd.IsDBNull(i) ? null : rd.GetValue(i);
            row[name] = val;
        }
        rows.Add(row);
    }
    return rows;
}

// === OFFLINE: lee un catálogo desde JSON para poder trabajar desde casa ===
static object LoadOfflineCatalog(string samplePath)
{
    var json = File.ReadAllText(samplePath);

    // Esperamos: [{"code":"...","name":"...","source":"..."}]
    // Si el JSON está bien formado, lo devolvemos como JsonElement (mantiene estructura).
    var doc = JsonDocument.Parse(json);
    return doc.RootElement.Clone();
}

static string FindOfflineSamplePath()
{
    var cwd = Directory.GetCurrentDirectory();

    var candidates = new[]
    {
        // Release: junto al exe
        Path.Combine(cwd, "config", "catalog.sample.json"),

        // Dev: ejecutando desde dist
        Path.GetFullPath(Path.Combine(cwd, "..", "config", "catalog.sample.json")),
        Path.GetFullPath(Path.Combine(cwd, "..", "..", "config", "catalog.sample.json")),

        // Dev: ejecutando desde apps/flutter_app/etiquetas_bodega (subir al repo root)
        Path.GetFullPath(Path.Combine(cwd, "..", "..", "..", "bridges", "mk_bridge", "config", "catalog.sample.json")),

        // Root del repo
        Path.GetFullPath(Path.Combine(cwd, "bridges", "mk_bridge", "config", "catalog.sample.json")),
    };

    foreach (var p in candidates.Distinct())
    {
        if (File.Exists(p)) return p;
    }

    throw new FileNotFoundException("catalog.sample.json no encontrado. Se esperaba en bridges/mk_bridge/config/catalog.sample.json o ./config/catalog.sample.json");
}

try
{
    if (args.Length == 0)
        return PrintErr(Err("", "INVALID_ARGS", "Falta comando (health|catalog|search|item)."), 2);

    var cmd = args[0].ToLowerInvariant();
    var requestId = ArgValue(args, "--request-id");

    if (cmd == "health")
        return PrintOk(Ok(requestId, new { status = "ok" }));

    // Modo offline para trabajar sin red clínica
    var offline = HasFlag(args, "--offline");

    switch (cmd)
    {
        case "catalog":
            {
                if (offline)
                {
                    try
                    {
                        var samplePath = FindOfflineSamplePath();
                        var items = LoadOfflineCatalog(samplePath);
                        return PrintOk(Ok(requestId, items));
                    }
                    catch (Exception ex)
                    {
                        return PrintErr(Err(requestId, "OFFLINE_FILE_NOT_FOUND", "No se encontró catalog.sample.json.", ex.Message), 4);
                    }
                }

                // === ONLINE (SQL real) ===
                string configPath;
                try
                {
                    configPath = FindConfigPath();
                }
                catch (Exception ex)
                {
                    return PrintErr(Err(requestId, "CONFIG_NOT_FOUND", "No se encontró config.xml.", ex.Message), 3);
                }

                try
                {
                    var (connectionString, sqlQuery) = LoadConfig(configPath);

                    using var cn = new SqlConnection(connectionString);
                    cn.Open();

                    using var sqlCmd = new SqlCommand(sqlQuery, cn);
                    sqlCmd.CommandTimeout = 20;

                    var rows = ReadRows(sqlCmd);

                    // Tu SELECT (foto) devuelve: CODARTICULO, NOMARTICULO
                    var items = rows.Select(r => new
                    {
                        code = (r.TryGetValue("CODARTICULO", out var c) ? c : null)?.ToString() ?? "",
                        name = (r.TryGetValue("NOMARTICULO", out var n) ? n : null)?.ToString() ?? "",
                        source = "BODEGA"
                    })
                    .Where(x => !string.IsNullOrWhiteSpace(x.code))
                    .ToList();

                    return PrintOk(Ok(requestId, items));
                }
                catch (SqlException ex)
                {
                    return PrintErr(Err(requestId, "DB_CONN_FAILED", "No se pudo conectar o ejecutar query SQL.", ex.Message), 10);
                }
                catch (Exception ex)
                {
                    return PrintErr(Err(requestId, "DB_QUERY_FAILED", "Fallo al ejecutar query.", ex.ToString()), 11);
                }
            }

        case "search":
            {
                // Si quieres implementar esto en SQL después, se hace con LIKE parametrizado.
                var q = ArgValue(args, "--q");
                return PrintOk(Ok(requestId, new { note = "search aún no implementado", q = q, offline = offline }));
            }

        case "item":
            {
                var code = ArgValue(args, "--code");
                return PrintOk(Ok(requestId, new { note = "item aún no implementado", code = code, offline = offline }));
            }

        default:
            return PrintErr(Err(requestId, "INVALID_ARGS", $"Comando desconocido: {cmd}."), 2);
    }
}
catch (Exception ex)
{
    var requestId = ArgValue(args, "--request-id");
    return PrintErr(Err(requestId, "UNEXPECTED_ERROR", "Fallo inesperado.", ex.ToString()), 90);
}