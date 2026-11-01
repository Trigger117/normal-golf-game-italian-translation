# Testing e segnalazioni / QA checklist

Questa checklist distingue i controlli eseguiti dai test ancora mancanti. Spuntare una voce solo dopo una prova in partita con GoogleTranslateV2 **disattivato**.

- [x] Plugin Beta 1.5 caricato da BepInEx
- [x] 881 termini I2 applicati (confermato nei log)
- [x] Descrizione della sfida *Isola minuscola 1* visualizzata in italiano
- [ ] Test delle altre sfide e dei testi con tasti dinamici
- [ ] Revisione completa dei dialoghi
- [ ] Controllo dei menu e delle scritte nel mondo di gioco
- [ ] Glossario: PAR, tee, green, draw, fade, hook, slice e colori distinti dai termini golfistici
- [ ] Test con `Endpoint=` e `FallbackEndpoint=` vuoti
- [ ] Test d'installazione su una copia pulita del gioco
- [ ] Pacchetto che include la DLL già compilata
- [ ] Verifica che il pacchetto non contenga DLL o asset originali del gioco

## Diagnostica / Debug

Il plugin Beta 1.5 produce log in `BepInEx/LogOutput.log`.
Con una sfida aperta, il tasto F9 salva un report in `BepInEx/normal-golf-italian/DIAGNOSTICA_F9.txt`.

Prima di condividere i file, oscurare eventuali percorsi o dati personali. I messaggi `NO_MATCH` possono comparire anche su testi già tradotti: non sono di per sé una prova di errore.
