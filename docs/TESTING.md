# Verifica della traduzione e segnalazioni

Questa lista distingue le verifiche già eseguite dai controlli ancora necessari. Per valutare la copertura offline, i test devono essere svolti con **GoogleTranslateV2 disattivato**.

- [x] Plugin Beta 1.5 caricato correttamente da BepInEx.
- [x] Applicazione di **881 voci I2**, confermata nei log.
- [x] Descrizione della sfida **«Isola minuscola 1»** visualizzata in italiano.
- [ ] Verifica di altre sfide, comprese quelle con tasti indicati dinamicamente.
- [ ] Revisione di tutti i dialoghi.
- [ ] Controllo dei menu e delle scritte nel mondo di gioco.
- [ ] Uniformità dei termini: `PAR`, `tee`, `green`, `draw`, `fade`, `hook`, `slice`; distinguere i termini golfistici dai colori.
- [ ] Funzionamento con `Endpoint=` e `FallbackEndpoint=` vuoti.
- [ ] Installazione su una copia pulita del gioco.
- [ ] Pacchetto pubblico contenente la DLL già compilata.
- [ ] Controllo dell'archivio per escludere DLL e asset originali del gioco.

## Diagnostica

Il plugin Beta 1.5 scrive il log in `BepInEx/LogOutput.log`.

Con una sfida aperta, premendo **F9** viene generato il rapporto:

`BepInEx/normal-golf-italian/DIAGNOSTICA_F9.txt`

Prima di condividere i log, oscura eventuali percorsi personali o informazioni private.

La dicitura `NO_MATCH` può comparire anche accanto a un testo già tradotto: **da sola non dimostra che la traduzione non funzioni**.
