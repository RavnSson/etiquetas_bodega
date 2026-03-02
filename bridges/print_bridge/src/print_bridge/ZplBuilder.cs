using System;
using System.Linq;
using System.Text;

namespace PrintBridge
{
    internal sealed class ZplBuilder
    {
        // Defaults conservadores:
        // 50x25mm ~ 400x200 dots @203dpi (aprox)
        public int WidthDots { get; }
        public int HeightDots { get; }

        public ZplBuilder(int widthDots = 400, int heightDots = 200)
        {
            WidthDots = Math.Max(200, widthDots);
            HeightDots = Math.Max(120, heightDots);
        }

        public string Build(string code, string name)
        {
            code = Sanitize(code, maxLen: 32);
            name = Sanitize(name, maxLen: 64);

            var lines = WrapSimple(name, lineLen: 28, maxLines: 2);

            var sb = new StringBuilder();
            sb.AppendLine("^XA");
            sb.AppendLine("^CI27"); // charset básico; suficiente para Latin-1 simple
            sb.AppendLine($"^PW{WidthDots}");
            sb.AppendLine($"^LL{HeightDots}");
            sb.AppendLine("^LH0,0");
            sb.AppendLine("^MD30"); // oscuridad (ajustable)

            // Código grande arriba
            sb.AppendLine("^FO20,15^A0N,35,35^FD" + EscapeZpl(code) + "^FS");

            // Code128
            sb.AppendLine("^BY2,2,60");
            sb.AppendLine("^FO20,60^BCN,60,Y,N,N^FD" + EscapeZpl(code) + "^FS");

            // Nombre abajo
            int y = 135;
            foreach (var line in lines)
            {
                sb.AppendLine($"^FO20,{y}^A0N,24,24^FD{EscapeZpl(line)}^FS");
                y += 26;
            }

            sb.AppendLine("^XZ");
            return sb.ToString();
        }

        private static string Sanitize(string s, int maxLen)
        {
            s = (s ?? "").Trim();
            if (s.Length == 0) s = "N/A";

            var filtered = new string(s.Where(ch => !char.IsControl(ch)).ToArray());
            if (filtered.Length > maxLen) filtered = filtered.Substring(0, maxLen);
            return filtered;
        }

        private static string EscapeZpl(string s)
        {
            // ^ y ~ son especiales en ZPL; lo simple: reemplazarlos.
            return s.Replace("^", " ").Replace("~", " ");
        }

        private static string[] WrapSimple(string s, int lineLen, int maxLines)
        {
            if (s.Length <= lineLen) return new[] { s };

            var words = s.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            var lines = new System.Collections.Generic.List<string>();
            var current = new StringBuilder();

            foreach (var w in words)
            {
                if (current.Length == 0)
                {
                    current.Append(w);
                    continue;
                }

                if (current.Length + 1 + w.Length <= lineLen)
                {
                    current.Append(' ').Append(w);
                }
                else
                {
                    lines.Add(current.ToString());
                    current.Clear();
                    current.Append(w);

                    if (lines.Count == maxLines - 1)
                        break;
                }
            }

            if (lines.Count < maxLines && current.Length > 0)
                lines.Add(current.ToString());

            // Truncar última línea si sobró
            if (lines.Count > 0 && lines.Count == maxLines)
            {
                var last = lines[maxLines - 1];
                if (last.Length > lineLen)
                    last = last.Substring(0, lineLen);
                lines[maxLines - 1] = last;
            }

            return lines.Take(maxLines).ToArray();
        }
    }
}