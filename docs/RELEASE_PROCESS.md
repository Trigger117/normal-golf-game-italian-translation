# Preparing a public beta / Preparazione della beta pubblica

The project's source data is **not a tested installer**. The internal 1.5.0 plugin has been tested in-game by the maintainer, but there has not yet been a full playthrough or a clean-install test.

## Version strategy
- Internal working plugin: **1.5.0**
- First public GitHub release: **v0.9.0-beta**, once a user-ready ZIP has been checked
- The version numbers distinguish a plugin's internal code version from the public distribution version.

## Build (Windows)
1. Install the original game, BepInEx 5 (Unity Mono), and XUnity.AutoTranslator (BepInEx).
2. Place `NormalGolfItalianI2.cs`, `CompilaPatch.ps1`, `i2_terms.tsv` and `ui_challenges.tsv` under `BepInEx/normal-golf-italian/`.
3. Place `ItalianoCompleto.txt` under `BepInEx/Translation/it/Text/`.
4. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\BepInEx\normal-golf-italian\CompilaPatch.ps1"` from the game root.
5. Start the game and confirm that `BepInEx/LogOutput.log` reports the plugin and `I2: applied 881 translated terms`.
6. Open a challenge and verify its description is displayed in Italian with GoogleTranslateV2 **disabled**.
7. Run `scripts/Build-Release.ps1` from the game root, or copy that script there and execute it. It generates `dist/NormalGolf_Italian_v0.9.0-beta.zip`.

## What the ZIP may contain

- `BepInEx/plugins/NormalGolfItalianI2.dll` compiled on Windows
- `BepInEx/normal-golf-italian/i2_terms.tsv`
- `BepInEx/normal-golf-italian/ui_challenges.tsv`
- `BepInEx/Translation/it/Text/ItalianoCompleto.txt`
- Installation instructions

**Do not ship:** `Assembly-CSharp.dll`, `resources.assets`, `UnityPlayer.dll`, game scenes, game sprites, user save files, or any original game binaries. Do not include automatically generated machine-translation caches.

## Clean-install acceptance criteria

- Download the packaged ZIP onto a fresh Windows copy of the game with compatible BepInEx and XUnity versions.
- Unzip into the folder containing `Normal Golf Game.exe`.
- Set `Language=it`, `FromLanguage=en`, `Endpoint=`, and `FallbackEndpoint=` in XUnity.
- Keep the game language set to English so the I2 replacement matches the original source language.
- Verify menu, dialogue, at least 3 different challenge descriptions, and a full restart.
- Check logs for exceptions, garbled placeholders, and broken rich-text tags.
- Review the ZIP and README before publishing GitHub release assets.

The first public version must be described as a **beta**; the 881 loaded entries do not by themselves demonstrate complete coverage.
