# Bridge Contract — etiquetas_bodega

## Objetivo
Flutter (frontend) se comunica con bridges (backend local) por CLI.
Los bridges son procesos ejecutables que:
- reciben comandos por argumentos (argv)
- devuelven JSON por STDOUT (siempre)
- escriben logs técnicos por STDERR (opcional)
- usan exit codes para indicar OK/ERROR

## Reglas globales
1) STDOUT SIEMPRE es JSON (incluso en error).
2) En éxito: exitCode = 0
3) En error: exitCode != 0 y/o payload ok=false
4) El JSON siempre tiene:
   - ok: boolean
   - meta: { bridge, version, ts, requestId }
   - error?: { code, message, details? }
5) requestId: Flutter lo genera y lo envía; el bridge lo devuelve igual.

## Formato JSON estándar
### Éxito
{
  "ok": true,
  "meta": {
    "bridge": "mk_bridge",
    "version": "1.0.0",
    "ts": "2026-03-01T12:00:00Z",
    "requestId": "..."
  },
  "data": ...
}

### Error
{
  "ok": false,
  "meta": { ... },
  "error": {
    "code": "DB_CONN_FAILED",
    "message": "No se pudo conectar a la BD",
    "details": "texto técnico opcional"
  }
}

## Exit codes (comunes)
0  OK
2  INVALID_ARGS
3  CONFIG_NOT_FOUND
4  CONFIG_INVALID
10 DB_CONN_FAILED
11 DB_QUERY_FAILED
20 PRINTER_NOT_FOUND
21 PRINTER_IO_ERROR
90 UNEXPECTED_ERROR
