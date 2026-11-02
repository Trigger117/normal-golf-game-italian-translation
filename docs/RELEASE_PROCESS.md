# Procedura di rilascio (Beta)

**Versione pubblica verificata su GitHub:** `v0.9.0-beta`, con ZIP per installazione manuale. La nuova Beta 0.9.1 e l'installer WPF non vanno annunciati come disponibili finché non compare una release con entrambi gli allegati.

## Sorgenti

- `plugin/`: plugin C# e script per compilarlo in un'installazione locale del gioco.
- `translations/`: dizionari italiani (fan translation; vedi `LICENSING.md`).
- `installer/`: UI WPF, worker PowerShell, launcher C++ e script di impacchettamento senza percorsi assoluti.
- `scripts/Build-Release.ps1`: crea lo ZIP della patch dai file della propria installazione.
- `scripts/Publish-WpfInstaller.ps1`: carica su una release **già esistente** un EXE il cui SHA-256 è stato verificato.

## Verifiche prima di pubblicare la nuova Beta

1. Verificare il funzionamento dell'installer grafico su Windows, inclusa l'icona della barra delle applicazioni.
2. Testare almeno una installazione pulita con BepInEx e XUnity assenti, compreso il download dei pacchetti e la verifica SHA-256.
3. Verificare il riavvio del gioco, menu e schermate di caricamento. Le nuove corrispondenze `Loading` e menu presenti nella beta 0.9.1 devono essere confermate nel gioco.
4. Assicurarsi che lo ZIP sia leggibile e che EXE e ZIP contengano la **stessa versione** della traduzione.
5. Controllare che non vengano pubblicati DLL, eseguibili o asset originali del gioco.
6. Creare il tag `v0.9.1-beta` e una pre-release con **installer EXE + ZIP**; non alterare la release precedente.
7. Soltanto dopo, aggiornare `README.md`, `CHANGELOG.md` e il collegamento pubblico al nuovo download.

## Caricamento mediante GitHub CLI

Per una release creata in precedenza e un installer EXE con hash noto, dalla radice del repository:

```powershell
.\scripts\Publish-WpfInstaller.ps1 -InstallerPath .\dist\NormalGolf_Installer_WPF.exe -Tag 'v0.9.1-beta' -ExpectedSha256 '<SHA-256 dell\'EXE verificato>'
```

Non usare `--clobber`: una release esistente non deve essere sovrascritta silenziosamente. La release pubblica corrente e la procedura manuale rimangono disponibili finché la nuova distribuzione non è stata collaudata.
