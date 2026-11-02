// Normal Golf Game - Italiano I2 + challenge UI fallback (BepInEx 5 / Unity Mono)
// Beta 1.5: corrected I2 Sources field lookup and prefixed challenge descriptions. No original game DLLs modified.
using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text.RegularExpressions;
using BepInEx;
using UnityEngine;

namespace NormalGolfItalian
{
    [BepInPlugin("com.community.normalgolf.italian", "Normal Golf Game - Italiano", "1.5.0")]
    public sealed class NormalGolfItalianI2 : BaseUnityPlugin
    {
        private sealed class UiRule
        {
            public string Key;
            public Regex Pattern;
            public string Anchor;
            public string Italian;
            public List<string> Variables;
        }
        private readonly Dictionary<string, string> translations = new Dictionary<string, string>(StringComparer.Ordinal);
        private readonly HashSet<object> patchedSources = new HashSet<object>();
        private readonly List<UiRule> uiRules = new List<UiRule>();
        private readonly Dictionary<string, PropertyInfo> textPropertyCache = new Dictionary<string, PropertyInfo>();
        private readonly HashSet<string> reported = new HashSet<string>();
        private int frames;
        private static readonly BindingFlags All = BindingFlags.Static | BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
        private static readonly Regex HtmlTag = new Regex(@"<[^<>]+>", RegexOptions.Compiled);
        private static readonly Regex WhiteSpace = new Regex(@"\s+", RegexOptions.Compiled);
        private static readonly Regex VariableToken = new Regex(@"\{[^{}]+\}|\[[^\[\]]+\]", RegexOptions.Compiled);
        private static readonly Regex BracedToken = new Regex(@"\{[^{}]+\}", RegexOptions.Compiled);
        private bool loaded;
        private MethodInfo keyDownMethod;
        private object keyF9;
        private bool diagnosticReady;

        private void Awake()
        {
            try
            {
                string dir = Path.Combine(Paths.BepInExRootPath, "normal-golf-italian");
                string terms = Path.Combine(dir, "i2_terms.tsv");
                if (!File.Exists(terms)) { Logger.LogError("Missing I2 translation: " + terms); return; }
                foreach (string line in File.ReadAllLines(terms, Encoding.UTF8))
                {
                    if (line.Length == 0 || line[0] == '#') continue;
                    int sep = line.IndexOf('\t');
                    if (sep <= 0) continue;
                    translations[line.Substring(0, sep)] = Decode(line.Substring(sep + 1));
                }
                string uiTerms = Path.Combine(dir, "ui_challenges.tsv");
                if (File.Exists(uiTerms))
                {
                    foreach (string line in File.ReadAllLines(uiTerms, Encoding.UTF8))
                    {
                        if (line.Length == 0 || line[0] == '#') continue;
                        string[] fields = line.Split(new char[] {'\t'}, 3);
                        if (fields.Length != 3) continue;
                        UiRule rule = BuildUiRule(Decode(fields[0]), Decode(fields[1]), Decode(fields[2]));
                        if (rule != null) uiRules.Add(rule);
                    }
                }
                loaded = translations.Count > 0;
                InitialiseDiagnosticHotkey();
                Logger.LogInfo("Italian 1.5: I2=" + translations.Count + ", challenge UI rules=" + uiRules.Count);
                PatchSources();
            }
            catch (Exception ex) { Logger.LogError("Italian 1.5 startup error: " + ex); }
        }

        private void Update()
        {
            if (!loaded) return;
            frames++;
            if (frames % 120 == 0) PatchSources();
            if (frames % 45 == 0) PatchVisibleChallengeTexts();
            if (frames == 120) Logger.LogInfo("Italian 1.5 ready. Press F9 with a challenge on screen for text diagnostics.");
            if (WasDiagnosticKeyPressed()) DumpUiDiagnostics();
        }

        // Escape sequences in generated TSV, preserving the literal markup.
        private static string Decode(string s)
        {
            StringBuilder b = new StringBuilder();
            for (int i = 0; i < s.Length; i++)
            {
                if (s[i] == '\\' && i + 1 < s.Length)
                {
                    char c = s[i + 1];
                    if (c == 'n') { b.Append('\n'); i++; continue; }
                    if (c == 'r') { b.Append('\r'); i++; continue; }
                    if (c == 't') { b.Append('\t'); i++; continue; }
                    if (c == '\\') { b.Append('\\'); i++; continue; }
                }
                b.Append(s[i]);
            }
            return b.ToString();
        }

        private static string Normalise(string s)
        {
            if (s == null) return "";
            // TMP color/size tags, I2 wiggle/swing tags are stripped only for matching.
            return WhiteSpace.Replace(HtmlTag.Replace(s, ""), " ").Trim();
        }

        private static UiRule BuildUiRule(string key, string original, string italian)
        {
            if (String.IsNullOrWhiteSpace(original) || String.IsNullOrWhiteSpace(italian)) return null;
            string cleaned = Normalise(original);
            StringBuilder pattern = new StringBuilder("^");
            List<string> variables = new List<string>();
            int start = 0;
            string anchor = "";
            MatchCollection tokens = VariableToken.Matches(cleaned);
            foreach (Match token in tokens)
            {
                string before = cleaned.Substring(start, token.Index - start);
                if (anchor.Length == 0 && before.Trim().Length >= 5) anchor = before.Trim();
                pattern.Append(Regex.Escape(before));
                pattern.Append("(.+?)");
                variables.Add(token.Value);
                start = token.Index + token.Length;
            }
            string last = cleaned.Substring(start);
            if (anchor.Length == 0 && last.Trim().Length >= 5) anchor = last.Trim();
            pattern.Append(Regex.Escape(last));
            // The game appends a separate control tip (e.g. [Must click hands to start swing])
            // to some challenge descriptions. Accept this tail without weakening the core match.
            pattern.Append(@"(?=$|\s+\[)");
            try
            {
                return new UiRule { Key = key, Pattern = new Regex(pattern.ToString(), RegexOptions.IgnoreCase | RegexOptions.CultureInvariant), Anchor = anchor,
                    Italian = italian, Variables = variables };
            }
            catch { return null; }
        }

        // For English descriptions that a game subsystem cached before the I2 source was patched.
        // Processes only active TextMeshPro/UI Text objects. Modifies displayed UI text, not the game data.
        private void PatchVisibleChallengeTexts()
        {
            try
            {
                Type[] candidates = { FindType("TMPro.TMP_Text"), FindType("UnityEngine.UI.Text") };
                foreach (Type textType in candidates)
                {
                    if (textType == null) continue;
                    PropertyInfo property = textType.GetProperty("text", All);
                    if (property == null || !property.CanRead || !property.CanWrite) continue;
                    UnityEngine.Object[] components = UnityEngine.Object.FindObjectsOfType(textType);
                    foreach (UnityEngine.Object item in components)
                    {
                        try
                        {
                            if (item == null) continue;
                            string existing = property.GetValue(item, null) as string;
                            if (String.IsNullOrWhiteSpace(existing)) continue;
                            // Labels rendered as a composed string (e.g. "MANAGEABLE - $125")
                            // are not necessarily intercepted by exact XUnity entries.
                            string adjusted = existing;
                            adjusted = Regex.Replace(adjusted, @"\bMANAGEABLE\b", "GESTIBILE", RegexOptions.IgnoreCase);
                            adjusted = Regex.Replace(adjusted, @"\bDIFFICULT\b", "DIFFICILE", RegexOptions.IgnoreCase);
                            adjusted = adjusted.Replace("Presa Spazio arrendersi", "Tieni premuto Spazio per rinunciare");
                            // Fix only UI elements whose purpose is known from F9 diagnostics.
                            string objectName = "";
                            Component actualComponent = item as Component;
                            if (actualComponent != null) objectName = actualComponent.gameObject.name;
                            if (objectName == "GiveUp")
                                adjusted = Regex.Replace(adjusted, @"^Presa\s+(<color=[^>]+>)Spazio</color>\s+arrendersi$", "Tieni premuto $1Spazio</color> per rinunciare", RegexOptions.IgnoreCase);
                            if (objectName == "PAR")
                                adjusted = Regex.Replace(adjusted, @"^PARAGRAFO(\s+\d+)", "PAR$1", RegexOptions.IgnoreCase);
                            if (objectName == "PAR (1)")
                                adjusted = Regex.Replace(adjusted, @"(?<=<size=8>)Sì$", "yd", RegexOptions.IgnoreCase);
                            if (objectName.StartsWith("Straight", StringComparison.Ordinal))
                            {
                                adjusted = adjusted.Replace(">Disegno<", ">Draw<").Replace(">Dissolvenza<", ">Fade<")
                                    .Replace(">Gancio<", ">Hook<").Replace(">Fetta<", ">Slice<")
                                    .Replace(">Verde<", ">Green<").Replace(">Scatola da T<", ">Tee box<");
                            }
                            if (adjusted != existing)
                            {
                                property.SetValue(item, adjusted, null);
                                existing = adjusted;
                            }
                            string clean = Normalise(existing);
                            if (clean.Length < 12) continue;
                            foreach (UiRule rule in uiRules)
                            {
                                if (rule.Anchor.Length >= 5 && clean.IndexOf(rule.Anchor, StringComparison.OrdinalIgnoreCase) < 0) continue;
                                Match match = rule.Pattern.Match(clean);
                                if (!match.Success) continue;
                                string result = MakeItalian(rule, match);
                                string remaining = clean.Substring(match.Length).Trim();
                                if (remaining.Length > 0)
                                {
                                    if (remaining.Equals("[Must click hands to start swing]", StringComparison.OrdinalIgnoreCase))
                                        result += " <color=#B4FFFD><size=22>[Clicca sulle mani per iniziare il colpo]</size></color>";
                                    else
                                    {
                                        // Do not discard instructions we do not yet understand.
                                        result += " " + remaining;
                                        if (reported.Add("suffix:" + rule.Key))
                                            Logger.LogWarning("Italian 1.5 UI unmatched instruction on " + rule.Key + ": " + remaining);
                                    }
                                }
                                if (result == existing) break;
                                property.SetValue(item, result, null);
                                if (reported.Add(rule.Key)) Logger.LogInfo("Italian 1.5 UI fallback: " + rule.Key);
                                break;
                            }
                        }
                        catch (Exception e)
                        {
                            if (reported.Add("uiitemerror")) Logger.LogWarning("Italian 1.5 UI item: " + e.Message);
                        }
                    }
                }
            }
            catch (Exception e) { if (reported.Add("uiscanerror")) Logger.LogWarning("Italian 1.5 UI scan: " + e.Message); }
        }

        private static string MakeItalian(UiRule rule, Match match)
        {
            // Preserve original colored text tags from the Italian source. Remove non-TMP custom
            // animation tags (wiggle/swing/etc.), since they were already processed by I2 upstream.
            string result = rule.Italian;
            for (int i = 0; i < rule.Variables.Count; i++)
            {
                string token = rule.Variables[i];
                string value = match.Groups[i + 1].Value;
                result = result.Replace(token, value);
            }
            result = Regex.Replace(result, @"</?(wiggle|swing|rainb|colorgold|code|whisper)[^>]*>", "", RegexOptions.IgnoreCase);
            return result;
        }

        // Diagnostic F9: non-invasive scan of all visible UI components.
        // Uses reflection so compilation doesn't need UnityEngine.InputLegacyModule.dll.
        private void InitialiseDiagnosticHotkey()
        {
            try
            {
                Type input = FindType("UnityEngine.Input");
                Type keyCode = FindType("UnityEngine.KeyCode");
                if (input == null || keyCode == null) return;
                keyDownMethod = input.GetMethod("GetKeyDown", All, null, new Type[] { keyCode }, null);
                if (keyDownMethod == null) return;
                keyF9 = Enum.Parse(keyCode, "F9");
                diagnosticReady = true;
                Logger.LogInfo("Italian 1.5 F9 diagnostics enabled.");
            }
            catch (Exception ex) { Logger.LogWarning("Italian 1.5 diagnostic key init failed: " + ex.Message); }
        }

        private bool WasDiagnosticKeyPressed()
        {
            if (!diagnosticReady) InitialiseDiagnosticHotkey();
            if (!diagnosticReady) return false;
            try { return (bool)keyDownMethod.Invoke(null, new object[] { keyF9 }); }
            catch (Exception ex)
            {
                diagnosticReady = false;
                if (reported.Add("f9error")) Logger.LogWarning("Italian 1.5 F9 diagnostic error: " + ex.Message);
                return false;
            }
        }

        private void DumpUiDiagnostics()
        {
            try
            {
                string file = Path.Combine(Paths.BepInExRootPath, "normal-golf-italian", "DIAGNOSTICA_F9.txt");
                using (StreamWriter writer = new StreamWriter(file, false, new UTF8Encoding(false)))
                {
                    writer.WriteLine("Normal Golf Italian 1.5 - diagnostic report");
                    writer.WriteLine("Captured UTC: " + DateTime.UtcNow.ToString("o"));
                    writer.WriteLine("I2 loaded terms: " + translations.Count + "; challenge fallback rules: " + uiRules.Count);
                    writer.WriteLine("I2 sources already patched: " + patchedSources.Count);
                    writer.WriteLine("Current scene: not queried (no additional assembly references)");
                    Type[] types = { FindType("TMPro.TMP_Text"), FindType("UnityEngine.UI.Text"), FindType("UnityEngine.TextMesh") };
                    foreach (Type textType in types)
                    {
                        if (textType == null) { writer.WriteLine("TEXT TYPE ABSENT"); continue; }
                        try
                        {
                            PropertyInfo p = textType.GetProperty("text", All);
                            if (p == null) { writer.WriteLine("NO text property: " + textType.FullName); continue; }
                            UnityEngine.Object[] components = UnityEngine.Object.FindObjectsOfType(textType);
                            writer.WriteLine("TYPE " + textType.FullName + ": " + components.Length + " active objects");
                            int count = 0;
                            foreach (UnityEngine.Object component in components)
                            {
                                string value = p.GetValue(component, null) as string;
                                if (String.IsNullOrWhiteSpace(value)) continue;
                                string plain = Normalise(value);
                                if (plain.Length == 0) continue;
                                string matchKey = "NO_MATCH";
                                foreach (UiRule rule in uiRules)
                                {
                                    if (rule.Anchor.Length >= 5 && plain.IndexOf(rule.Anchor, StringComparison.OrdinalIgnoreCase) < 0) continue;
                                    if (rule.Pattern.IsMatch(plain)) { matchKey = rule.Key; break; }
                                }
                                string path = "unknown";
                                try
                                {
                                    Component comp = component as Component;
                                    if (comp != null) path = comp.gameObject.name;
                                }
                                catch { }
                                writer.WriteLine("TEXT [" + (++count) + "] " + path + " | " + matchKey);
                                writer.WriteLine("RAW: " + value.Replace("\r", "\\r").Replace("\n", "\\n"));
                            }
                        }
                        catch (Exception scanError) { writer.WriteLine("TYPE ERROR " + textType.FullName + ": " + scanError); }
                    }
                }
                Logger.LogInfo("Italian 1.5 F9 diagnostic written: " + file);
            }
            catch (Exception ex) { Logger.LogError("Italian 1.5 F9 diagnostic failed: " + ex); }
        }

        private void PatchSources()
        {
            try
            {
                Type manager = FindType("I2.Loc.LocalizationManager");
                if (manager == null)
                {
                    if (frames > 240 && reported.Add("i2-no-manager")) Logger.LogWarning("Italian 1.5 I2: LocalizationManager type not loaded.");
                    return;
                }
                // Critical fix: in I2 Localization `Sources` is a PUBLIC STATIC FIELD,
                // not necessarily a property. The old property-only lookup always returned null.
                FieldInfo sourcesField = manager.GetField("Sources", All);
                PropertyInfo sourcesProp = sourcesField == null ? manager.GetProperty("Sources", All) : null;
                if (sourcesField == null && sourcesProp == null)
                {
                    if (reported.Add("i2-no-sources")) Logger.LogWarning("Italian 1.5 I2: LocalizationManager.Sources member not found.");
                    return;
                }
                object sourcesValue = sourcesField != null ? sourcesField.GetValue(null) : sourcesProp.GetValue(null, null);
                IEnumerable sources = sourcesValue as IEnumerable;
                if (sources == null)
                {
                    if (reported.Add("i2-sources-null")) Logger.LogWarning("Italian 1.5 I2: Sources is null.");
                    return;
                }
                int modified = 0;
                int inspected = 0;
                foreach (object source in sources)
                {
                    if (source == null || patchedSources.Contains(source)) continue;
                    inspected++;
                    IList langs = GetMember(source, "mLanguages") as IList;
                    IList terms = GetMember(source, "mTerms") as IList;
                    if (langs == null || terms == null || terms.Count == 0) continue;
                    int en = FindEnglish(langs);
                    if (en < 0) continue;
                    int here = 0;
                    foreach (object term in terms)
                    {
                        if (term == null) continue;
                        string key = GetMember(term, "Term") as string;
                        string italian;
                        if (key == null || !translations.TryGetValue(key, out italian)) continue;
                        string[] values = GetMember(term, "Languages") as string[];
                        if (values == null || en >= values.Length) continue;
                        values[en] = italian;
                        here++;
                    }
                    if (here > 0)
                    {
                        patchedSources.Add(source);
                        modified += here;
                        Logger.LogInfo("Italian 1.5 I2: patched " + here + " terms in " + source.GetType().Name);
                    }
                }
                if (inspected > 0 && modified == 0 && reported.Add("i2-zero"))
                    Logger.LogWarning("Italian 1.5 I2: " + inspected + " sources inspected but no matching terms modified. Check source keys/languages.");
                if (modified > 0)
                {
                    MethodInfo setLang = manager.GetMethod("SetLanguage", All, null,
                        new Type[] { typeof(string), typeof(bool), typeof(bool) }, null);
                    if (setLang != null) setLang.Invoke(null, new object[] { "English", false, true });
                    MethodInfo localize = manager.GetMethod("LocalizeAll", All, null,
                        new Type[] { typeof(bool) }, null);
                    if (localize != null) localize.Invoke(null, new object[] { true });
                    Logger.LogInfo("Italian 1.5 I2: applied " + modified + " translated terms.");
                }
            }
            catch (Exception ex) { if (reported.Add("i2error")) Logger.LogWarning("Italian 1.5 I2 error: " + ex.Message); }
        }

        private static int FindEnglish(IList langs)
        {
            for (int i = 0; i < langs.Count; i++)
            {
                object lang = langs[i];
                if (lang == null) continue;
                string name = GetMember(lang, "Name") as string;
                string code = GetMember(lang, "Code") as string;
                if (String.Equals(name, "English", StringComparison.OrdinalIgnoreCase) ||
                    String.Equals(code, "en", StringComparison.OrdinalIgnoreCase)) return i;
            }
            return -1;
        }
        private static Type FindType(string name)
        {
            foreach (Assembly a in AppDomain.CurrentDomain.GetAssemblies())
            {
                Type t = a.GetType(name, false);
                if (t != null) return t;
            }
            return null;
        }
        private static object GetMember(object obj, string name)
        {
            Type t = obj.GetType();
            FieldInfo f = t.GetField(name, All);
            if (f != null) return f.GetValue(obj);
            PropertyInfo p = t.GetProperty(name, All);
            if (p != null) return p.GetValue(obj, null);
            return null;
        }
    }
}
