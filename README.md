# 🇮🇹 Normal Golf Game — Traduzione italiana

Traduzione amatoriale **non ufficiale** di **Normal Golf Game**, dedicata ai giocatori italiani.

> **Beta 0.9 pubblicata!** Puoi scaricare la traduzione dalla sezione **[Releases](../../releases/tag/v0.9.0-beta)**. È una versione sperimentale: alcune schermate potrebbero avere ancora testi in inglese. L'installer automatico è in fase di prova; al momento la release contiene il pacchetto ZIP per l'installazione manuale.

## Cosa viene tradotto

Il progetto mira a tradurre in italiano:

- Dialoghi e testi narrativi.
- Menu e interfaccia.
- Titoli, descrizioni e istruzioni delle sfide.
- Altre scritte presenti nel mondo di gioco, quando tecnicamente accessibili.

**Le voci originali restano in inglese.** Manteniamo inoltre i termini tecnici del golf, come *par*, *green*, *fairway*, *tee*, *draw*, *fade*, *hook* e *slice*, quando sono usati nel loro significato sportivo.

## Stato della traduzione

La versione sperimentale attualmente provata è la **Beta 1.5**.

- **881 voci I2 Localization** risultano applicate correttamente al database durante una prova reale, come confermato dal log del plugin.
- Il sistema dispone anche di **358 regole** per riconoscere descrizioni di sfide nell'interfaccia.
- È stata verificata nel gioco la descrizione italiana della sfida **«Isola minuscola 1»**, precedentemente rimasta in inglese.
- **Non tutte le sfide, i dialoghi e le schermate sono stati testati**: possono ancora esserci testi in inglese, traduzioni da correggere o problemi di compatibilità.

Questi numeri descrivono i dati caricati, **non una copertura garantita al 100%**.

## Requisiti

- Una copia Windows di **Normal Golf Game**.
- [BepInEx 5 per Unity Mono](https://github.com/BepInEx/BepInEx/releases).
- [XUnity.AutoTranslator per BepInEx](https://github.com/bbepis/XUnity.AutoTranslator/releases), utilizzato per alcuni testi esterni al catalogo I2.

## Download e installazione

È disponibile la prima **[release pubblica v0.9.0-beta](../../releases/tag/v0.9.0-beta)**, con il plugin già compilato. Scarica l'archivio **`NormalGolf_Italian_v0.9.0-beta.zip`**, installa BepInEx 5 e XUnity.AutoTranslator, quindi estrai il contenuto dello ZIP nella cartella che contiene `Normal Golf Game.exe`. Segui le indicazioni di configurazione nelle note della release e nel file `LEGGIMI.txt` incluso nell'archivio. L'installer automatico è ancora in fase di test.

Il plugin sperimentale interviene sulle traduzioni caricate in memoria e non richiede di sostituire l'eseguibile del gioco, `Assembly-CSharp.dll` o `resources.assets`.

## Problemi noti e test

- [Problemi noti](docs/KNOWN_ISSUES.md)
- [Verifiche eseguite e test ancora da fare](docs/TESTING.md)
- [Procedura di preparazione della release](docs/RELEASE_PROCESS.md)
- [Cronologia delle modifiche](CHANGELOG.md)

## Segnalazioni e suggerimenti

Per segnalare una traduzione errata o un malfunzionamento, apri una [segnalazione su GitHub](../../issues) e indica, se possibile:

1. La versione della patch e quella del gioco.
2. Il testo originale, la traduzione attuale e quella suggerita.
3. Uno screenshot e i passaggi per raggiungere la schermata.
4. Per problemi tecnici, le righe pertinenti di `BepInEx/LogOutput.log` e, se richiesto, `BepInEx/normal-golf-italian/DIAGNOSTICA_F9.txt`.

**Oscura eventuali percorsi personali e dati privati presenti nei log prima di condividerli.**

## Avvertenze

Questa è una traduzione amatoriale, **non ufficiale e non affiliata agli sviluppatori o agli editori di Normal Golf Game**. Tutti i diritti relativi al gioco, ai suoi nomi e ai suoi contenuti appartengono ai rispettivi titolari.

Il progetto richiede una copia legittima del gioco e non intende distribuire eseguibili o asset originali.
