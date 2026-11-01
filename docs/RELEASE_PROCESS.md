# Preparazione della prima beta pubblica

**I dati e i sorgenti del progetto non costituiscono ancora un pacchetto di installazione collaudato.** Il plugin interno 1.5.0 è stato provato nel gioco, ma manca una verifica dell'intera campagna e dell'installazione su una copia pulita.

## Numerazione delle versioni

- **1.5.0:** versione interna del plugin attualmente utilizzata per i test.
- **v0.9.0-beta:** nome previsto per la prima release pubblica su GitHub, una volta verificato il pacchetto.

Questi numeri distinguono la versione tecnica del plugin da quella del pacchetto distribuito ai giocatori.

## Compilazione su Windows

1. Installa il gioco originale, **BepInEx 5 per Unity Mono** e **XUnity.AutoTranslator per BepInEx**.
2. Copia `NormalGolfItalianI2.cs`, `CompilaPatch.ps1`, `i2_terms.tsv` e `ui_challenges.tsv` in `BepInEx/normal-golf-italian/`.
3. Copia `ItalianoCompleto.txt` in `BepInEx/Translation/it/Text/`.
4. Apri PowerShell nella cartella principale del gioco ed esegui:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\BepInEx\normal-golf-italian\CompilaPatch.ps1"
   ```

5. Avvia il gioco e controlla in `BepInEx/LogOutput.log` che compaiano il caricamento del plugin e il messaggio `I2: applied 881 translated terms`.
6. Apri una sfida e verifica la descrizione in italiano con **GoogleTranslateV2 disattivato**.
7. Esegui lo script `scripts/Build-Release.ps1` dalla cartella principale del gioco, oppure copialo lì prima di eseguirlo. Il risultato previsto è `dist/NormalGolf_Italian_v0.9.0-beta.zip`.

## Contenuto previsto dell'archivio pubblico

- `BepInEx/plugins/NormalGolfItalianI2.dll` compilata su Windows.
- `BepInEx/normal-golf-italian/i2_terms.tsv`.
- `BepInEx/normal-golf-italian/ui_challenges.tsv`.
- `BepInEx/Translation/it/Text/ItalianoCompleto.txt`.
- Istruzioni di installazione.

**Non includere:** `Assembly-CSharp.dll`, `resources.assets`, `UnityPlayer.dll`, scene, immagini, salvataggi, eseguibili o altri contenuti originali del gioco. Non includere vecchie cache di traduzione automatica.

## Verifiche prima della pubblicazione

1. Prepara una copia Windows pulita del gioco con versioni compatibili di BepInEx e XUnity.
2. Estrai lo ZIP nella cartella contenente `Normal Golf Game.exe`.
3. Configura XUnity con `Language=it`, `FromLanguage=en`, `Endpoint=` e `FallbackEndpoint=`.
4. Mantieni **English** come lingua originale nelle impostazioni del gioco.
5. Controlla menu, dialoghi, almeno tre descrizioni diverse delle sfide e il comportamento dopo il riavvio.
6. Verifica l'assenza di eccezioni nei log, segnaposto corrotti e tag di formattazione non validi.
7. Ricontrolla il contenuto dello ZIP e le istruzioni prima di caricarlo nelle GitHub Releases.

La prima versione pubblica deve essere presentata come **beta**: il caricamento di 881 voci I2, da solo, non dimostra una copertura completa.
