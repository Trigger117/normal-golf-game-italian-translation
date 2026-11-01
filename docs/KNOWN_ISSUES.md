# Known issues / Problemi noti

- **Not fully playtested:** Not every scene or challenge has been checked in-game.
- **XUnity cache interference:** Older automatically generated translations may still say `PARAGRAFO`, `Disegno`, `Dissolvenza`, `Gancio` or `Fetta`. These are not correct when referring to *Par*, *Draw*, *Fade*, *Hook* and *Slice*. Prefer offline/manual translations for testing and keep old caches out of the release ZIP.
- **Glossary by context:** Words like *green* can refer to either a golf surface or the color. Don't globally replace every occurrence without checking where the term is used.
- **Interface compatibility:** Modded Unity TextMesh Pro components can change after game updates. Logs and the F9 diagnostics can help identify a failing UI text component.
- **Runtime versus catalog:** A translation present in `i2_terms.tsv` is not proof it appears correctly on screen. The internal 1.5.0 test confirmed the I2 source was patched and the *Isola minuscola 1* challenge description appeared in Italian, but not every challenge has been validated.
- **Dependency:** This translation needs third-party BepInEx/XUnity installed separately.

Report problems in [GitHub Issues](../issues), ideally with a screenshot, the game version, the patch version, and sanitized relevant log lines.
