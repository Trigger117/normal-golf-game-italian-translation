# Pubblicazione e verifica delle release

## Stato attuale

La prima release pubblica è **[v0.9.0-beta](https://github.com/Trigger117/normal-golf-game-italian-translation/releases/tag/v0.9.0-beta)**, pubblicata il **1 novembre 2026**. Contiene uno ZIP da installare manualmente.

L'**installer grafico WPF** è in prova su Windows; la sua pubblicazione come allegato separato è in preparazione. Non indicarlo come disponibile finché non compare negli allegati della release.

## Numerazione delle versioni

- **1.5:** versione interna del plugin BepInEx verificata in gioco.
- **v0.9.0-beta:** versione della distribuzione ZIP pubblica.
- **WPF v1.x (test):** numerazione delle build sperimentali dell'installer, non delle release pubbliche.

I numeri non sono intercambiabili.

## Checklist prima di pubblicare un aggiornamento

1. Controlla che il pacchetto contenga la DLL della patch, `i2_terms.tsv`, `ui_challenges.tsv`, `ItalianoCompleto.txt` e le istruzioni.
2. Verifica che **non** contenga `Assembly-CSharp.dll`, `resources.assets`, `UnityPlayer.dll`, eseguibili del gioco, scene, immagini o salvataggi originali.
3. Conferma la validità dello ZIP e confronta gli SHA-256 con il pacchetto approvato.
4. Prova l'installazione su Windows, preferibilmente anche con BepInEx e XUnity assenti, e verifica l'integrità dei download.
5. Avvia il gioco, mantenendo **English** come lingua originale, e controlla menu, dialoghi e almeno tre descrizioni diverse delle sfide.
6. Ripeti il test dopo il riavvio, verifica la gestione dei backup e l'assenza di eccezioni nei log.
7. Nelle note di pubblicazione indica chiaramente i **problemi noti** e che la traduzione è sperimentale.

## Installer WPF

Quando una build sarà stata verificata:

- Allegare l'eseguibile nella stessa release o in una nuova release dedicata, specificando che si tratta di un installer e non del gioco completo.
- Lasciare disponibile anche lo ZIP per chi preferisce l'installazione manuale.
- Aggiornare contemporaneamente README, note della release e guida Steam.
- Non attribuire alla versione pubblica eventuali correzioni presenti soltanto nelle build di test.

Per i dettagli sulle verifiche vedi [TESTING.md](TESTING.md).

## Indicazioni per i contributori

Il pacchetto disponibile su GitHub Releases è **già compilato**. I sorgenti dell'installer di prova e gli script usati localmente per creare gli archivi non sono ancora tutti caricati nel repository; le presenti istruzioni non costituiscono una procedura di compilazione autonoma dal solo checkout GitHub.
