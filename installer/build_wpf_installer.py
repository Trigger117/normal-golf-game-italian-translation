#!/usr/bin/env python3
"""Genera l'EXE dell'installer WPF da un launcher Win64 compilato e da una patch ZIP.

Richiede Python 3.9+, `pe_icon_resource.py` e nessun percorso fisso all'ambiente di sviluppo.
Il launcher nativo può essere compilato su Windows dai sorgenti in launcher/launcher.cpp.
La patch ZIP si ottiene dalla compilazione del plugin o da una release verificata.
"""
from __future__ import annotations
import argparse
import base64
import hashlib
import struct
import re
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path
from pe_icon_resource import stamp

ROOT = Path(__file__).resolve().parent
REQUIRED = {
    'BepInEx/normal-golf-italian/i2_terms.tsv',
    'BepInEx/normal-golf-italian/ui_challenges.tsv',
    'BepInEx/plugins/NormalGolfItalianI2.dll',
    'BepInEx/Translation/it/Text/ItalianoCompleto.txt',
    'LEGGIMI.txt',
}
PLACEHOLDERS = {
    '__XAML_BASE64__': ROOT / 'src/MainWindow.xaml',
    '__WORKER_BASE64__': ROOT / 'src/Installer.Worker.ps1',
    '__BANNER_BASE64__': ROOT / 'assets/banner_golf.jpg',
    '__ICON_BASE64__': ROOT / 'assets/app_icon.png',
    '__ICO_BASE64__': ROOT / 'assets/app_icon.ico',
}


def build(patch_path: Path, stub_path: Path, output: Path) -> str:
    patch = patch_path.read_bytes()
    with zipfile.ZipFile(patch_path) as z:
        if z.testzip() is not None or not REQUIRED.issubset(z.namelist()):
            raise ValueError('Archivio patch non valido oppure mancano file richiesti')
        forbidden = ('Assembly-CSharp.dll', 'resources.assets', 'UnityPlayer.dll', 'Normal Golf Game.exe')
        if any(name.rsplit('/', 1)[-1] in forbidden for name in z.namelist()):
            raise ValueError('La patch contiene file originali del gioco: rimuoverli')
    ET.parse(PLACEHOLDERS['__XAML_BASE64__'])
    main = (ROOT/'src/Installer.Wpf.ps1').read_text(encoding='utf-8-sig')
    for placeholder, file in PLACEHOLDERS.items():
        if main.count(placeholder) != 1:
            raise ValueError(f'Placeholder mancante o duplicato: {placeholder}')
        payload = file.read_bytes()
        if placeholder == '__WORKER_BASE64__':
            worker = payload.decode('utf-8-sig')
            worker, count = re.subn(r"(?m)^(\$hashPatch\s*=\s*')[0-9a-fA-F]{64}(')$", lambda m: m.group(1) + hashlib.sha256(patch).hexdigest() + m.group(2), worker)
            if count != 1:
                raise ValueError('Hash ZIP nel worker mancante o duplicato')
            payload = worker.encode('utf-8-sig')
        main = main.replace(placeholder, base64.b64encode(payload).decode('ascii'))
    if any(p in main for p in PLACEHOLDERS):
        raise ValueError('Placeholder rimasti nel risultato')
    if any(c in main for c in '\u2018\u2019\u201c\u201d'):
        raise ValueError('Controllare gli apostrofi tipografici nel sorgente PowerShell')
    # L'host PowerShell avvia e intercetta le eccezioni dello script dell'interfaccia.
    wrapper = ("param([Parameter(Mandatory=$true)][string]$ArchivioPatch)\n"
               "$ErrorActionPreference='Stop'\n"
               "$log=Join-Path $env:TEMP 'NormalGolf_Installer_WPF.log'\n"
               "try {\n    $installer = @'\n" + main.rstrip('\n') + "\n'@\n"
               "    & ([ScriptBlock]::Create($installer)) -ArchivioPatch $ArchivioPatch\n"
               "} catch {\n"
               "    try { Add-Content -LiteralPath $log -Value ($_ | Out-String) } catch {}\n"
               "    $message=\"Errore durante l'avvio dell'installer: \"+$_.Exception.Message+\"`nLog: \"+$log\n"
               "    try { Add-Type -AssemblyName PresentationFramework;"
               " [void][System.Windows.MessageBox]::Show($message,'Normal Golf Game - Errore') }"
               " catch { Write-Host $message }\n    exit 1\n}\n")
    if wrapper.count("    $installer = @'\n") != 1 or wrapper.count("\n'@\n") != 1:
        raise ValueError('Delimitatori here-string invalidi')
    stub = stub_path.read_bytes()
    if stub[:2] != b'MZ':
        raise ValueError('Il launcher deve essere un PE Win64 (MZ)')
    if stub[-16:-8] == b'NGIP2026':
        a,b = struct.unpack('<II',stub[-8:])
        stub = stub[:-16-a-b]  # rimuove un eventuale overlay precedente
    # A public installer may already contain the icon resource.
    pe = struct.unpack_from('<I', stub, 0x3c)[0]
    resource_rva, resource_size = struct.unpack_from('<II', stub, pe + 24 + 112 + 16)
    exe = stub if resource_rva and resource_size else stamp(stub, (ROOT/'assets/app_icon.ico').read_bytes())
    encoded = b'\xff\xfe' + wrapper.encode('utf-16le')
    exe += encoded + patch + b'NGIP2026' + struct.pack('<II',len(encoded),len(patch))
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_bytes(exe)
    return hashlib.sha256(exe).hexdigest()


if __name__ == '__main__':
    cli = argparse.ArgumentParser(description='Build dell\'installer WPF per Normal Golf Game')
    cli.add_argument('--patch',required=True,type=Path,help='ZIP della patch italiana verificata')
    cli.add_argument('--stub',required=True,type=Path,help='launcher.exe compilato dal C++ incluso')
    cli.add_argument('--output',type=Path,default=ROOT/'dist/NormalGolf_Installer_WPF.exe')
    args=cli.parse_args()
    digest=build(args.patch,args.stub,args.output)
    print(f'EXE creato: {args.output}\nSHA-256: {digest}')
