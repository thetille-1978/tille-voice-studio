using System.Diagnostics;
using System.Globalization;
using System.IO.Compression;
using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;

namespace GhostingAnalyticsReport;

internal static class Program
{
    private static readonly Uri DashboardUri =
        new("https://ghosting-vs-stalking.tille1978.chatgpt.site/admin/analytics");

    public static async Task<int> Main()
    {
        Console.OutputEncoding = Encoding.UTF8;
        Console.Title = "Ghosting vs. Stalking – Analytics PDF";

        WriteBanner();

        try
        {
            string token = ReadSecret("Admin-Schlüssel: ");
            if (string.IsNullOrWhiteSpace(token))
            {
                ShowError("Es wurde kein Admin-Schlüssel eingegeben.");
                return 1;
            }

            Console.WriteLine();
            Console.WriteLine("Analytics der letzten 7 Tage werden sicher abgerufen …");

            string dashboardHtml = await FetchDashboardAsync(token.Trim());
            token = string.Empty;

            List<string> reportLines = ExtractSevenDayReport(dashboardHtml);
            string pdfPath = GetOutputPath();

            MinimalPdfWriter.Write(pdfPath, reportLines);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine();
            Console.WriteLine("Fertig. Der PDF-Bericht wurde erstellt:");
            Console.ResetColor();
            Console.WriteLine(pdfPath);

            try
            {
                Process.Start(new ProcessStartInfo(pdfPath) { UseShellExecute = true });
            }
            catch
            {
                // Die PDF ist trotzdem erfolgreich erstellt.
            }

            Console.WriteLine();
            Console.WriteLine("Du kannst dieses Fenster jetzt schließen.");
            return 0;
        }
        catch (HttpRequestException)
        {
            ShowError("Die Website konnte nicht erreicht werden. Bitte prüfe deine Internetverbindung.");
            return 2;
        }
        catch (UnauthorizedAccessException)
        {
            ShowError("Die PDF konnte im gewählten Ordner nicht gespeichert werden.");
            return 3;
        }
        catch (Exception ex)
        {
            ShowError(ex.Message);
            return 4;
        }
    }

    private static void WriteBanner()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("Ghosting vs. Stalking");
        Console.WriteLine("Analytics-Bericht – letzte 7 Tage");
        Console.ResetColor();
        Console.WriteLine(new string('─', 48));
        Console.WriteLine("Der Schlüssel wird nur für diesen Abruf verwendet");
        Console.WriteLine("und weder in der EXE noch in der PDF gespeichert.");
        Console.WriteLine();
    }

    private static string ReadSecret(string prompt)
    {
        Console.Write(prompt);
        var value = new StringBuilder();

        while (true)
        {
            ConsoleKeyInfo key = Console.ReadKey(intercept: true);
            if (key.Key == ConsoleKey.Enter)
            {
                Console.WriteLine();
                break;
            }

            if (key.Key == ConsoleKey.Backspace)
            {
                if (value.Length > 0)
                {
                    value.Length--;
                    Console.Write("\b \b");
                }
                continue;
            }

            if (!char.IsControl(key.KeyChar))
            {
                value.Append(key.KeyChar);
                Console.Write('•');
            }
        }

        return value.ToString();
    }

    private static HttpClient CreateClient(CookieContainer cookies)
    {
        var handler = new HttpClientHandler
        {
            CookieContainer = cookies,
            AllowAutoRedirect = true,
            AutomaticDecompression = DecompressionMethods.All
        };

        var client = new HttpClient(handler)
        {
            Timeout = TimeSpan.FromSeconds(30)
        };
        client.DefaultRequestHeaders.UserAgent.ParseAdd(
            "GhostingAnalyticsReport/1.0 (+Windows PDF Export)");
        client.DefaultRequestHeaders.Accept.Add(
            new MediaTypeWithQualityHeaderValue("text/html"));
        return client;
    }

    private static async Task<string> FetchDashboardAsync(string token)
    {
        var cookies = new CookieContainer();
        using var client = CreateClient(cookies);

        string loginHtml = await client.GetStringAsync(DashboardUri);
        if (LooksLikeDashboard(loginHtml))
            return loginHtml;

        string formHtml = FindLoginForm(loginHtml);
        string action = GetAttribute(
            Regex.Match(formHtml, "(?is)<form\\b[^>]*>").Value, "action");
        Uri postUri = string.IsNullOrWhiteSpace(action)
            ? DashboardUri
            : new Uri(DashboardUri, WebUtility.HtmlDecode(action));

        var fields = ParseHiddenFields(formHtml);
        string credentialField = FindCredentialField(formHtml);
        fields[credentialField] = token;

        using (var response = await client.PostAsync(
                   postUri, new FormUrlEncodedContent(fields)))
        {
            string html = await response.Content.ReadAsStringAsync();
            if (LooksLikeDashboard(html))
                return html;
        }

        string dashboard = await client.GetStringAsync(
            new Uri(DashboardUri + "?days=7"));
        if (LooksLikeDashboard(dashboard))
            return dashboard;

        // Kompatibilitätsversuch für serverseitige Bearer-/Header-Authentifizierung.
        using var headerClient = CreateClient(new CookieContainer());
        headerClient.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", token);
        headerClient.DefaultRequestHeaders.TryAddWithoutValidation(
            "X-Admin-Token", token);

        using var headerResponse = await headerClient.GetAsync(
            new Uri(DashboardUri + "?days=7"));
        string headerHtml = await headerResponse.Content.ReadAsStringAsync();
        if (LooksLikeDashboard(headerHtml))
            return headerHtml;

        throw new InvalidOperationException(
            "Der Admin-Schlüssel wurde nicht akzeptiert oder die Anmeldung am Analytics-Dashboard hat sich geändert.");
    }

    private static bool LooksLikeDashboard(string html) =>
        Regex.IsMatch(
            WebUtility.HtmlDecode(html),
            @"(?is)letzte\s*7\s*tage");

    private static string FindLoginForm(string html)
    {
        foreach (Match match in Regex.Matches(html, "(?is)<form\\b[^>]*>.*?</form>"))
        {
            string form = match.Value;
            if (Regex.IsMatch(form, "(?is)type\\s*=\\s*(['\"]?)password\\1") ||
                Regex.IsMatch(form, "(?is)name\\s*=\\s*(['\"]?)[^'\" >]*(token|password|key)[^'\" >]*\\1"))
                return form;
        }

        Match first = Regex.Match(html, "(?is)<form\\b[^>]*>.*?</form>");
        if (first.Success)
            return first.Value;

        throw new InvalidOperationException(
            "Die Anmeldemaske des Analytics-Dashboards konnte nicht erkannt werden.");
    }

    private static Dictionary<string, string> ParseHiddenFields(string formHtml)
    {
        var fields = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (Match input in Regex.Matches(formHtml, "(?is)<input\\b[^>]*>"))
        {
            string tag = input.Value;
            string type = GetAttribute(tag, "type");
            string name = GetAttribute(tag, "name");
            if (name.Length == 0 || !type.Equals("hidden", StringComparison.OrdinalIgnoreCase))
                continue;
            fields[name] = WebUtility.HtmlDecode(GetAttribute(tag, "value"));
        }
        return fields;
    }

    private static string FindCredentialField(string formHtml)
    {
        string fallback = "token";
        foreach (Match input in Regex.Matches(formHtml, "(?is)<input\\b[^>]*>"))
        {
            string tag = input.Value;
            string name = GetAttribute(tag, "name");
            string type = GetAttribute(tag, "type");

            if (type.Equals("password", StringComparison.OrdinalIgnoreCase))
                return name.Length > 0 ? name : fallback;

            if (name.Contains("token", StringComparison.OrdinalIgnoreCase) ||
                name.Contains("password", StringComparison.OrdinalIgnoreCase) ||
                name.Contains("key", StringComparison.OrdinalIgnoreCase))
                fallback = name;
        }
        return fallback;
    }

    private static string GetAttribute(string tag, string attribute)
    {
        if (string.IsNullOrEmpty(tag))
            return string.Empty;

        string quotedPattern =
            "(?is)\\b" + Regex.Escape(attribute) + "\\s*=\\s*(['\"])(.*?)\\1";
        Match quoted = Regex.Match(tag, quotedPattern);
        if (quoted.Success)
            return quoted.Groups[2].Value;

        string plainPattern =
            "(?is)\\b" + Regex.Escape(attribute) + "\\s*=\\s*([^\\s>]+)";
        Match plain = Regex.Match(tag, plainPattern);
        return plain.Success ? plain.Groups[1].Value.Trim('\'', '"') : string.Empty;
    }

    private static List<string> ExtractSevenDayReport(string html)
    {
        List<string> dashboardLines = HtmlToLines(html);
        int start = dashboardLines.FindIndex(
            x => Normalize(x).Contains("letzte 7 tage", StringComparison.Ordinal));

        if (start < 0)
            throw new InvalidOperationException(
                "Der Bereich „Letzte 7 Tage“ wurde im Dashboard nicht gefunden.");

        int end = dashboardLines.Count;
        for (int i = start + 1; i < dashboardLines.Count; i++)
        {
            string normalized = Normalize(dashboardLines[i]);
            if (normalized.Contains("letzte 30 tage", StringComparison.Ordinal) ||
                normalized is "gesamt" or "gesamt:")
            {
                end = i;
                break;
            }
        }

        DateTimeOffset now = DateTimeOffset.Now;
        DateTimeOffset from = now.Date.AddDays(-6);

        var result = new List<string>
        {
            "GHOSTING VS. STALKING",
            "ANALYTICS-BERICHT – LETZTE 7 TAGE",
            "",
            "Website: https://ghosting-vs-stalking.tille1978.chatgpt.site",
            $"Zeitraum: {from:dd.MM.yyyy} bis {now:dd.MM.yyyy}",
            $"Erstellt: {now:dd.MM.yyyy HH:mm}",
            "",
            "ÜBERSICHT"
        };

        for (int i = start + 1; i < end; i++)
        {
            string line = CleanLine(dashboardLines[i]);
            if (line.Length > 0 && !IsNoise(line))
                result.Add(line);
        }

        if (result.Count <= 9)
            throw new InvalidOperationException(
                "Im 7-Tage-Bereich wurden keine auswertbaren Kennzahlen gefunden.");

        result.Add("");
        result.Add("Hinweis");
        result.Add("Der Bericht übernimmt die serverseitig berechneten Kennzahlen des geschützten Analytics-Dashboards. Eigene als Test markierte Besuche bleiben entsprechend der Dashboard-Logik ausgeschlossen.");

        return result;
    }

    private static List<string> HtmlToLines(string html)
    {
        string text = Regex.Replace(html, "(?is)<script\\b[^>]*>.*?</script>", " ");
        text = Regex.Replace(text, "(?is)<style\\b[^>]*>.*?</style>", " ");
        text = Regex.Replace(text, "(?is)<svg\\b[^>]*>.*?</svg>", " ");

        text = Regex.Replace(text, "(?is)</(h[1-6]|p|div|section|article|header|footer|li|tr)>", "\n");
        text = Regex.Replace(text, "(?is)<br\\s*/?>", "\n");
        text = Regex.Replace(text, "(?is)</(th|td)>", " | ");
        text = Regex.Replace(text, "(?is)<[^>]+>", " ");
        text = WebUtility.HtmlDecode(text).Replace('\u00a0', ' ');

        var lines = new List<string>();
        foreach (string raw in text.Split('\n'))
        {
            string line = Regex.Replace(raw, @"[ \t\r]+", " ").Trim();
            line = Regex.Replace(line, @"(?:\s*\|\s*){2,}", " | ").Trim(' ', '|');
            if (line.Length == 0)
                continue;
            if (lines.Count == 0 || !line.Equals(lines[^1], StringComparison.OrdinalIgnoreCase))
                lines.Add(line);
        }
        return lines;
    }

    private static bool IsNoise(string line)
    {
        string n = Normalize(line);
        return n is "abmelden" or "zuruck" or "dashboard" ||
               n.StartsWith("ghosting vs stalking", StringComparison.Ordinal);
    }

    private static string Normalize(string value)
    {
        string n = value.ToLowerInvariant()
            .Replace('ä', 'a').Replace('ö', 'o').Replace('ü', 'u')
            .Replace("ß", "ss");
        return Regex.Replace(n, @"\s+", " ").Trim();
    }

    private static string CleanLine(string line) =>
        Regex.Replace(line, @"\s*\|\s*$", string.Empty).Trim();

    private static string GetOutputPath()
    {
        string fileName =
            $"Ghosting-vs-Stalking_Analytics_7-Tage_{DateTime.Now:yyyy-MM-dd}.pdf";
        string preferred = Path.Combine(AppContext.BaseDirectory, fileName);

        try
        {
            using FileStream test = new(
                preferred, FileMode.Create, FileAccess.Write, FileShare.None);
            test.Close();
            File.Delete(preferred);
            return preferred;
        }
        catch
        {
            string documents = Environment.GetFolderPath(
                Environment.SpecialFolder.MyDocuments);
            return Path.Combine(documents, fileName);
        }
    }

    private static void ShowError(string message)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine();
        Console.WriteLine("Fehler: " + message);
        Console.ResetColor();
        Console.WriteLine();
        Console.WriteLine("Drücke eine Taste, um das Fenster zu schließen.");
        Console.ReadKey(intercept: true);
    }
}

internal static class MinimalPdfWriter
{
    private const int MaxChars = 92;
    private const int LinesPerPage = 54;

    public static void Write(string path, IReadOnlyList<string> sourceLines)
    {
        List<string> lines = new();
        foreach (string source in sourceLines)
            lines.AddRange(Wrap(ToPdfText(source), MaxChars));

        if (lines.Count == 0)
            lines.Add("Keine Daten.");

        var pages = lines
            .Select((line, index) => new { line, index })
            .GroupBy(x => x.index / LinesPerPage)
            .Select(g => g.Select(x => x.line).ToList())
            .ToList();

        using var output = new MemoryStream();
        var offsets = new List<long> { 0 };

        void WriteAscii(string value)
        {
            byte[] bytes = Encoding.ASCII.GetBytes(value);
            output.Write(bytes, 0, bytes.Length);
        }

        WriteAscii("%PDF-1.4\n%PDFREPORT\n");

        int objectCount = 3 + pages.Count * 2;
        var pageObjectNumbers = new List<int>();

        WriteObject(1, "<< /Type /Catalog /Pages 2 0 R >>");
        for (int i = 0; i < pages.Count; i++)
            pageObjectNumbers.Add(4 + i * 2);

        string kids = string.Join(" ", pageObjectNumbers.Select(n => $"{n} 0 R"));
        WriteObject(2, $"<< /Type /Pages /Kids [{kids}] /Count {pages.Count} >>");
        WriteObject(3, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");

        for (int i = 0; i < pages.Count; i++)
        {
            int pageObj = 4 + i * 2;
            int streamObj = pageObj + 1;
            WriteObject(pageObj,
                $"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] " +
                $"/Resources << /Font << /F1 3 0 R >> >> /Contents {streamObj} 0 R >>");

            string stream = BuildPageStream(pages[i], i + 1, pages.Count);
            offsets.Add(output.Position);
            WriteAscii($"{streamObj} 0 obj\n");
            WriteAscii($"<< /Length {Encoding.ASCII.GetByteCount(stream)} >>\nstream\n");
            WriteAscii(stream);
            WriteAscii("\nendstream\nendobj\n");
        }

        long xrefPosition = output.Position;
        WriteAscii($"xref\n0 {objectCount + 1}\n");
        WriteAscii("0000000000 65535 f \n");
        for (int i = 1; i <= objectCount; i++)
            WriteAscii($"{offsets[i]:0000000000} 00000 n \n");

        WriteAscii($"trailer\n<< /Size {objectCount + 1} /Root 1 0 R >>\n");
        WriteAscii($"startxref\n{xrefPosition}\n%%EOF\n");

        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        File.WriteAllBytes(path, output.ToArray());

        void WriteObject(int number, string body)
        {
            offsets.Add(output.Position);
            WriteAscii($"{number} 0 obj\n{body}\nendobj\n");
        }
    }

    private static string BuildPageStream(
        IReadOnlyList<string> lines, int pageNumber, int totalPages)
    {
        var sb = new StringBuilder();
        sb.Append("BT\n/F1 9 Tf\n42 795 Td\n12 TL\n");

        foreach (string line in lines)
        {
            sb.Append('(').Append(Escape(line)).Append(") Tj\nT*\n");
        }

        sb.Append("ET\n");
        sb.Append("BT\n/F1 8 Tf\n42 24 Td\n(")
          .Append(Escape($"Seite {pageNumber} von {totalPages}"))
          .Append(") Tj\nET");
        return sb.ToString();
    }

    private static IEnumerable<string> Wrap(string value, int width)
    {
        if (value.Length == 0)
        {
            yield return string.Empty;
            yield break;
        }

        string remaining = value;
        while (remaining.Length > width)
        {
            int breakAt = remaining.LastIndexOf(' ', width);
            if (breakAt < width / 2)
                breakAt = width;
            yield return remaining[..breakAt].TrimEnd();
            remaining = remaining[breakAt..].TrimStart();
        }
        yield return remaining;
    }

    private static string Escape(string value) =>
        value.Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)");

    private static string ToPdfText(string value)
    {
        var replacements = new Dictionary<char, string>
        {
            ['ä'] = "ae", ['ö'] = "oe", ['ü'] = "ue",
            ['Ä'] = "Ae", ['Ö'] = "Oe", ['Ü'] = "Ue",
            ['ß'] = "ss", ['–'] = "-", ['—'] = "-", ['…'] = "...",
            ['„'] = "\"", ['“'] = "\"", ['”'] = "\"", ['’'] = "'",
            ['•'] = "-", ['→'] = "->", ['€'] = "EUR"
        };

        var result = new StringBuilder();
        foreach (char c in value)
        {
            if (replacements.TryGetValue(c, out string? replacement))
                result.Append(replacement);
            else if (c >= 32 && c <= 126)
                result.Append(c);
            else
                result.Append('?');
        }
        return result.ToString();
    }
}
