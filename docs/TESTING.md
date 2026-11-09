# Checklist di verifica della traduzione

Per controllare che la traduzione funzioni senza servizi online, effettuare i test con GoogleTranslateV2 disattivato.

- [x] Plugin interno Beta 1.5 caricato correttamente da BepInEx.
- [x] Applicazione di **881 voci I2** confermata nei log.
- [x] Descrizione della sfida **«Isola minuscola 1»** visualizzata in italiano.
- [x] Pacchetto ZIP pubblico contenente la DLL compilata.
- [x] Beta 0.9.2: workflow GitHub completato con successo; ZIP e installer WPF sincronizzati mediante confronto byte per byte.
- [ ] Beta 0.9.2: test diretto della nuova build EXE su Windows.
- [x] Verifica strutturale dell'archivio ZIP per escludere DLL e asset originali del gioco.
- [x] Installer WPF provato su una cartella di gioco già predisposta, con installazione completata e backup registrato.
- [ ] Test dell'installer WPF su un sistema pulito, con download delle dipendenze non ancora installate.
- [ ] Controllo di ulteriori sfide, comprese quelle con tasti indicati dinamicamente.
- [ ] Revisione di tutti i dialoghi.
- [ ] Revisione completa dei menu e delle scritte nel mondo di gioco.
- [ ] Verifica delle stringhe `Change Difficulty`, `Sound Settings`, `Video Settings`, `Gameplay Settings`, `Delete Saves` e `Loading` dopo le correzioni.
- [ ] Uniformità dei termini golfistici (`par`, `tee`, `green`, `draw`, `fade`, `hook`, `slice`).
- [ ] Verifica dell'installazione manuale su una copia pulita del gioco.
- [ ] Controllo di un'intera partita e del funzionamento dopo più riavvii.
- [x] Installer WPF e ZIP pubblicati come allegati nella release `v0.9.1-beta`.
- [ ] Test del download e avvio dell'installer su un secondo sistema Windows.

## Diagnostica

Il plugin scrive nel file `BepInEx/LogOutput.log`.

Con una sfida aperta, premendo **F9** viene generato il rapporto `BepInEx/normal-golf-italian/DIAGNOSTICA_F9.txt`.

Prima di condividere i log, oscura eventuali percorsi o informazioni private. La dicitura `NO_MATCH` può comparire anche accanto a testi già tradotti e non dimostra, da sola, un malfunzionamento.
