# Procedura di rilascio (Beta)

**Versione pubblica:** [`v0.9.1-beta`](https://github.com/Trigger117/normal-golf-game-italian-translation/releases/tag/v0.9.1-beta), con installer WPF e ZIP manuale. La precedente `v0.9.0-beta` rimane disponibile. I test dell'installer su una installazione completamente pulita sono ancora da completare.

## Sorgenti

- `plugin/`: plugin C# e script per compilarlo in un'installazione locale del gioco.
- `translations/`: dizionari italiani (fan translation; vedi `LICENSING.md`).
- `installer/`: UI WPF, worker PowerShell, launcher C++ e script di impacchettamento senza percorsi assoluti.
- `scripts/Build-Release.ps1`: crea lo ZIP della patch dai file della propria installazione.
- `scripts/Publish-WpfInstaller.ps1`: carica su una release **già esistente** un EXE il cui SHA-256 è stato verificato.

## Verifiche prima di dichiarare stabile la Beta o pubblicare un aggiornamento successivo

1. Verificare il funzionamento dell'installer grafico su Windows, inclusa l'icona della barra delle applicazioni.
2. Testare almeno una installazione pulita con BepInEx e XUnity assenti, compreso il download dei pacchetti e la verifica SHA-256.
3. Verificare il riavvio del gioco, menu e schermate di caricamento. Le nuove corrispondenze `Loading` e menu presenti nella beta 0.9.1 devono essere confermate nel gioco.
4. Assicurarsi che lo ZIP sia leggibile e che EXE e ZIP contengano la **stessa versione** della traduzione.
5. Controllare che non vengano pubblicati DLL, eseguibili o asset originali del gioco.
6. Per aggiornamenti successivi, creare un nuovo tag e una nuova pre-release con **installer EXE + ZIP**; non alterare la release precedente.
7. Aggiornare contestualmente `README.md`, `CHANGELOG.md` e i link alla release pubblicata.

## Caricamento mediante GitHub CLI

Per una release creata in precedenza e un installer EXE con hash noto, dalla radice del repository:

```powershell
.\scripts\Publish-WpfInstaller.ps1 -InstallerPath .\dist\NormalGolf_Installer_WPF.exe -Tag '<nuovo-tag>' -ExpectedSha256 '<SHA-256 dell\'EXE verificato>'
```

Non usare `--clobber`: una release esistente non deve essere sovrascritta silenziosamente. L'installer pubblico è ancora sperimentale; non indicare come verificati i test non effettuati.
