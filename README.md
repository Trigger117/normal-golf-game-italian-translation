# 🇮🇹 Normal Golf Game — Traduzione italiana

**Traduzione amatoriale, gratuita e non ufficiale di Normal Golf Game**, dedicata ai giocatori italiani.

La patch traduce dialoghi, menu, interfaccia e descrizioni delle sfide. Il doppiaggio rimane in inglese; i termini tecnici del golf, come *par*, *green*, *draw*, *fade*, *hook* e *slice*, vengono mantenuti nella lingua originale quando appropriato.

> **Versione pubblica: [Beta 0.9 — v0.9.0-beta](https://github.com/Trigger117/normal-golf-game-italian-translation/releases/tag/v0.9.0-beta).** La traduzione è utilizzabile ma ancora sperimentale. Alcuni testi possono essere rimasti in inglese o richiedere correzioni.

## 📥 Download

**[Scarica la traduzione italiana da GitHub Releases](https://github.com/Trigger117/normal-golf-game-italian-translation/releases/tag/v0.9.0-beta)**

Al momento la release pubblica contiene **`NormalGolf_Italian_v0.9.0-beta.zip`**, con il plugin già compilato.

### 🛠️ Installazione manuale

1. Chiudi completamente il gioco.
2. Installa [BepInEx 5 per Unity Mono](https://github.com/BepInEx/BepInEx/releases) e [XUnity.AutoTranslator per BepInEx](https://github.com/bbepis/XUnity.AutoTranslator/releases).
3. Scarica `NormalGolf_Italian_v0.9.0-beta.zip` dalla release.
4. Estrai il contenuto nella cartella contenente `Normal Golf Game.exe`. Non occorre sostituire l'eseguibile né i file originali del gioco.
5. Nel file di configurazione di XUnity, sotto `BepInEx/config`, imposta:

   ```ini
   Language=it
   FromLanguage=en
   Endpoint=
   FallbackEndpoint=
   ```

6. Avvia il gioco mantenendo **English** come lingua originale.

Se XUnity non ha ancora creato il suo file di configurazione, avvia il gioco una volta dopo averlo installato. Se hai usato traduzioni automatiche in precedenza, consulta `LEGGIMI.txt` nello ZIP per evitare interferenze con vecchie cache.

### 🖥️ Installer automatico Windows

È stato sviluppato un **installer grafico WPF** che permette di scegliere la cartella del gioco, installare BepInEx e XUnity se mancanti, configurare la traduzione e conservare backup dei file sovrascritti.

**L'installer è ancora in fase di verifica e non è attualmente allegato alla release GitHub.** Finché non sarà pubblicato, utilizza la procedura manuale indicata sopra.

## 📋 Stato e copertura

- **881 voci I2 Localization** applicate e confermate nei log durante i test.
- **358 regole** aggiuntive per le descrizioni delle sfide.
- Verificata in gioco almeno una descrizione di sfida, «Isola minuscola 1», precedentemente non tradotta.
- Test non ancora completi per tutte le schermate, le sfide e i dialoghi.

La versione interna del plugin è **1.5**; il numero della distribuzione pubblica è **0.9 Beta**. I numeri descrivono componenti diversi e non indicano che tutte le stringhe del gioco siano state controllate.

## 🐛 Segnalazioni e aggiornamenti

Hai trovato un testo in inglese, una traduzione poco naturale o un problema tecnico? **[Apri una segnalazione (Issues)](https://github.com/Trigger117/normal-golf-game-italian-translation/issues)**, possibilmente con screenshot, versione della patch e una breve descrizione della schermata.

Per i problemi tecnici puoi allegare estratti di `BepInEx/LogOutput.log` (e, se necessario, `BepInEx/normal-golf-italian/DIAGNOSTICA_F9.txt`), dopo aver oscurato eventuali percorsi personali.

Altre informazioni:
- [Cronologia delle modifiche](CHANGELOG.md)
- [Problemi noti](docs/KNOWN_ISSUES.md)
- [Checklist di verifica](docs/TESTING.md)

## ⚖️ Avvertenze

Progetto amatoriale **non ufficiale**, non affiliato né approvato da Luke Muscat o dagli altri titolari dei diritti di Normal Golf Game. Tutti i diritti relativi al gioco restano ai rispettivi proprietari.

La traduzione è gratuita, richiede una copia legittima del gioco e non include il gioco completo o i suoi file originali.
