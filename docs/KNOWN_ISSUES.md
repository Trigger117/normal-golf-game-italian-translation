# Problemi noti

- **Test di gioco non ancora completi:** non tutte le schermate, le sfide e i dialoghi sono stati verificati.
- **Voci delle impostazioni e caricamento:** nella Beta 0.9.1 sono state aggiunte corrispondenze offline per `Change Difficulty`, `Sound Settings`, `Video Settings`, `Gameplay Settings`, `Delete Saves` e `Loading`. Non tutte sono state verificate nel gioco: `Loading` potrebbe apparire prima che il sistema di traduzione venga inizializzato.
- **Interferenze delle vecchie cache XUnity:** traduzioni precedenti possono ancora mostrare `PARAGRAFO`, `Disegno`, `Dissolvenza`, `Gancio` o `Fetta` al posto dei termini golfistici *Par*, *Draw*, *Fade*, *Hook* e *Slice*.
- **Terminologia da verificare in base al contesto:** *green* può indicare la superficie di gioco oppure il colore verde.
- **Compatibilità dell'interfaccia:** gli aggiornamenti del gioco possono modificare i componenti TextMesh Pro. I log e la diagnostica F9 aiutano a identificare le stringhe non intercettate.
- **Catalogo e visualizzazione non sono la stessa cosa:** una traduzione presente in `i2_terms.tsv` non garantisce automaticamente che appaia correttamente a schermo.
- **Installer automatico:** disponibile nella release 0.9.1. Il funzionamento con BepInEx e XUnity già presenti è stato verificato; il download da zero delle dipendenze richiede ancora un test dedicato.

Per segnalare problemi, apri una [segnalazione su GitHub](../issues) e aggiungi, se possibile, screenshot, versione della patch, versione del gioco e righe pertinenti dei log, senza informazioni personali.
