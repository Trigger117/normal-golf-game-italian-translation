#!/usr/bin/env python3
"""Crea uno ZIP distribuzione con la DLL verificata della release precedente
e i dizionari aggiornati del repository. Non include i binari del gioco.
"""
import argparse
import hashlib
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DLL = "BepInEx/plugins/NormalGolfItalianI2.dll"
DLL_SHA256 = "0d6470017ce475634d6d6273a5e2886076773402cd70e7538ccda3cf04b04977"
FILES = {
    "BepInEx/normal-golf-italian/i2_terms.tsv": "translations/i2_terms.tsv",
    "BepInEx/normal-golf-italian/ui_challenges.tsv": "translations/ui_challenges.tsv",
    "BepInEx/Translation/it/Text/ItalianoCompleto.txt": "translations/ItalianoCompleto.txt",
}
INSTRUCTIONS = """Normal Golf Game - Traduzione italiana Beta 0.9.2 (non ufficiale)

INSTALLAZIONE MANUALE
1. Chiudi Normal Golf Game.
2. Installa BepInEx 5 (Unity Mono) e XUnity.AutoTranslator per BepInEx.
3. Estrai l'archivio nella cartella contenente Normal Golf Game.exe.
4. In BepInEx/config/AutoTranslatorConfig.ini imposta:
   Language=it
   FromLanguage=en
   Endpoint=
   FallbackEndpoint=
5. Avvia il gioco mantenendo la lingua originale English.

Per aggiornare dalla Beta 0.9.1, chiudi il gioco e sovrascrivi i file della patch.
In caso di traduzioni obsolete, controlla le vecchie cache di XUnity.

Novita': Thin Shot, Topped Shot, Fat Shot e Chip Shot mantenuti in inglese
nei contesti golfistici. Corretta la descrizione Salta il bunker.
Versione sperimentale: non tutte le schermate sono state verificate.
La modifica non contiene correzioni per i crash nativi del gioco.
Progetto gratuito e non ufficiale. Richiede una copia legittima del gioco.
Non include file originali di Normal Golf Game.
"""

def package(previous: Path, destination: Path):
    with zipfile.ZipFile(previous) as original:
        dll = original.read(DLL)
    if dll[:2] != b"MZ" or hashlib.sha256(dll).hexdigest() != DLL_SHA256:
        raise ValueError("DLL della release di origine non verificata")
    payloads = {name: (ROOT / path).read_bytes() for name, path in FILES.items()}
    for name, data in payloads.items():
        if not data or b"\x00" in data:
            raise ValueError(f"File non valido: {name}")
        data.decode("utf-8-sig")
    i2 = payloads["BepInEx/normal-golf-italian/i2_terms.tsv"].decode("utf-8-sig")
    if "Terms/Thin\t<color=#FFEB00>Thin Shot</color>" not in i2 or "Challenges/BO_BB3_0\tCerca di non toccare la sabbia" not in i2:
        raise ValueError("Correzioni non presenti nei dizionari")
    ui = payloads["BepInEx/normal-golf-italian/ui_challenges.tsv"].decode("utf-8-sig")
    if sum(bool(s) and not s.startswith("#") for s in ui.splitlines()) < 350:
        raise ValueError("Regole delle sfide incomplete")
    destination.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as out:
        out.writestr(DLL, dll)
        for name, data in payloads.items():
            out.writestr(name, data)
        out.writestr("LEGGIMI.txt", INSTRUCTIONS.encode("utf-8-sig"))
    with zipfile.ZipFile(destination) as check:
        if check.testzip() is not None or len(check.namelist()) != 5:
            raise ValueError("Archivio generato non valido")
    print("ZIP generato:", destination, "SHA256", hashlib.sha256(destination.read_bytes()).hexdigest())

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--previous-release-zip", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    package(args.previous_release_zip, args.output)
