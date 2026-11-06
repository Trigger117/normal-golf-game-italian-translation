# Cronologia delle modifiche

## In sviluppo — Termini golfistici (non ancora distribuiti)

- Ripristinati i nomi tecnici **Thin Shot**, **Topped Shot** e **Fat Shot** nei termini dinamici colorati del gioco.
- Corretta la frase della sfida **«Salta il bunker»** per eliminare la duplicazione «colpo Colpo sottile» e mantenere «Thin Shot».
- Allineate le descrizioni di sfide che richiedono esplicitamente un **Chip Shot**, inclusa **«Asso del minigolf»**; gli approcci generici restano in italiano.
- Aggiornati insieme `i2_terms.tsv`, `ui_challenges.tsv` e le corrispondenze disponibili in `ItalianoCompleto.txt`.
- **Non ancora testato in gioco e non incluso negli allegati della release pubblica v0.9.1-beta.**

## v0.9.1-beta — 2 novembre 2026 (release pubblica)

- Pubblicati **installer WPF Windows** e ZIP per l'installazione manuale.
- Nuova interfaccia grafica con cartella gioco, avanzamento, log, backup e selezione automatica delle dipendenze mancanti.
- Aggiunte corrispondenze offline per diverse voci delle impostazioni e per `Loading` (la visualizzazione effettiva non è ancora verificata in tutte le schermate).
- Pubblicati i sorgenti del plugin, dell'installer e i dizionari, con licenza e avvertenze sui contenuti del gioco.
- Test in ambiente già predisposto completati; installazione pulita delle dipendenze ancora da verificare.


## Ancora da verificare

- Test completo dell'installer grafico Windows **WPF** con download delle dipendenze assenti e controllo dopo più riavvii.
- Preparazione di correzioni per ulteriori testi dei menu e delle schermate di caricamento, da verificare nel gioco prima della prossima release.
- Revisione continua della terminologia golfistica e dei testi residui in inglese.

## v0.9.0-beta — Prima release pubblica (1 novembre 2026)

- Primo archivio ZIP della traduzione italiana, con plugin già compilato.
- **881 voci** di I2 Localization gestite dalla patch.
- **358 regole** di supporto per le descrizioni delle sfide.
- File di traduzione offline e istruzioni per l'installazione manuale tramite BepInEx 5 e XUnity.AutoTranslator.
- Release contrassegnata come **beta**, perché i controlli durante il gioco non sono ancora completi.

## Beta interna 1.5 — Versione tecnica del plugin

- Corretto l'accesso a `LocalizationManager.Sources` per I2 Localization.
- Confermata nei log l'applicazione di 881 voci I2.
- Migliorata la gestione delle descrizioni delle sfide con istruzioni aggiunte dinamicamente.
- Aggiunte le regole alternative per intercettare i testi dell'interfaccia.
- Introdotta la diagnostica F9.

> **Nota:** 1.5 è la versione interna del plugin; 0.9 è la versione della distribuzione pubblica.
