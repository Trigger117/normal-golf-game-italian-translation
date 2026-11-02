# Plugin BepInEx — sorgenti

`NormalGolfItalianI2.cs` contiene il plugin di localizzazione I2 e la gestione delle descrizioni delle sfide. `CompilaPatch.ps1` compila il plugin dentro un'installazione locale di Normal Golf Game che abbia BepInEx e le DLL Unity necessarie.

1. Copia `NormalGolfItalianI2.cs` e `CompilaPatch.ps1` in `BepInEx/normal-golf-italian/` della tua installazione del gioco.
2. Copia `translations/i2_terms.tsv` e `translations/ui_challenges.tsv` nella stessa cartella e `translations/ItalianoCompleto.txt` in `BepInEx/Translation/it/Text/`.
3. Esegui da PowerShell `./BepInEx/normal-golf-italian/CompilaPatch.ps1` dalla cartella del gioco. È consigliato un .NET SDK recente.
4. Usa `scripts/Build-Release.ps1` per creare un pacchetto ZIP con **solo** plugin compilato, dizionari e istruzioni.

Le DLL originali di Unity, del gioco e di BepInEx **non vanno caricate su questo repository**. La versione del plugin non coincide con il numero della release pubblica.
