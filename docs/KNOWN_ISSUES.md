# Problemi noti

- **Test di gioco non ancora completi:** non tutte le schermate, le sfide e i dialoghi sono stati verificati.
- **Interferenze delle vecchie cache XUnity:** traduzioni automatiche precedenti possono ancora mostrare `PARAGRAFO`, `Disegno`, `Dissolvenza`, `Gancio` o `Fetta`. Queste traduzioni sono scorrette quando il testo originale indica i termini sportivi *Par*, *Draw*, *Fade*, *Hook* e *Slice*. Per verificare la patch usare traduzioni manuali/offline e non distribuire vecchie cache.
- **Terminologia da interpretare nel contesto:** *green* può indicare la superficie di gioco oppure il colore verde. Evitare sostituzioni globali della parola.
- **Compatibilità dell'interfaccia:** gli aggiornamenti del gioco possono modificare i componenti TextMesh Pro. I log e la diagnostica F9 permettono di individuare testi che non vengono intercettati.
- **Catalogo e visualizzazione non sono la stessa cosa:** la presenza di una traduzione in `i2_terms.tsv` non garantisce che appaia correttamente sullo schermo. Il test della Beta 1.5 conferma l'aggiornamento del database I2 e la traduzione della sfida **«Isola minuscola 1»**, ma non di tutte le altre sfide.
- **Dipendenze esterne:** per ora BepInEx e XUnity.AutoTranslator devono essere installati separatamente.

Per segnalare problemi, apri una [segnalazione su GitHub](../../issues), preferibilmente con screenshot, versione del gioco, versione della patch e righe pertinenti dei log senza dati personali.
