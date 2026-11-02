# Installer Windows WPF — sorgenti

Questa cartella contiene il **sorgente dell'installer WPF pubblicato come beta**, non l'eseguibile del gioco. L'interfaccia è in `src/MainWindow.xaml`, la logica UI in `src/Installer.Wpf.ps1` e il motore d'installazione in `src/Installer.Worker.ps1`.

## Requisiti per ricompilare

- Windows x64, Windows PowerShell 5.1 e WPF (inclusi in Windows).
- Python 3.9+ per `build_wpf_installer.py`.
- Un compilatore Win64 capace di compilare `launcher/launcher.cpp` (ad es. MSVC/Windows SDK); produce `launcher.exe`, il piccolo avviatore nativo.
- Uno **ZIP della patch** già verificato, contenente `NormalGolfItalianI2.dll`, dizionari e `LEGGIMI.txt`, ottenuto dai propri file build oppure dalla release ufficiale.

Esempio da terminale Windows, dopo aver compilato `launcher.cpp` e ottenuto `launcher.exe`:

```powershell
python installer/build_wpf_installer.py --stub installer/launcher/launcher.exe --patch .\NormalGolf_Italian_v0.9.0-beta.zip --output .\dist\NormalGolf_Installer_WPF.exe
```

Il comando non utilizza percorsi assoluti hardcoded, non scarica il gioco e genera un file con risorse icona incorporate. La distribuzione pubblica della Beta 0.9.1 si trova [nelle Releases](../releases/tag/v0.9.1-beta). **Compilare il launcher Windows e verificare l'installazione su Windows sono comunque necessari; la build non è stata convalidata come pipeline completamente automatica.**

Il formato tecnico dell'EXE è `[launcher Win64][script PowerShell UTF-16LE][patch ZIP][NGIP2026 + due lunghezze]`. La `launcher.cpp` ne estrae temporaneamente il contenuto all'avvio.

L'installer scarica BepInEx e XUnity dalle rispettive release pubbliche **solo se necessari** e confronta le impronte SHA-256 previste dal worker. Aggiornando i numeri di versione delle dipendenze, aggiornare anche gli hash e testarli nuovamente.

Non caricare nel repository gli eseguibili/DLL originali del gioco o copie personali di salvataggi, cache e log.
