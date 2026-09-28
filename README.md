# Glitchlings

Mobile-Monster-Sammelspiel – Konzept, spielbarer Prototyp und Sprites.

## Loslegen
1. Diesen Ordner an einen festen Ort legen, z. B. `Dokumente/glitchlings`.
2. Prototyp ansehen: `prototype/index.html` im Browser öffnen.
3. Game Design lesen: Ordner `vault` in Obsidian als Vault öffnen.

## Mit Claude Code weiterarbeiten
**Desktop-App:** Claude-App öffnen → Bereich „Code“ → diesen Ordner als Projektordner auswählen.
**Terminal:**
```
cd Pfad/zu/glitchlings
claude
```
Claude liest automatisch `CLAUDE.md` und kennt damit den ganzen Projektstand.
Ein guter erster Satz: *„Lies CLAUDE.md und gib mir einen kurzen Überblick, dann machen wir mit den nächsten Schritten weiter.“*

## PixelLab anbinden (für bessere Pixel-Art)
1. Konto auf https://www.pixellab.ai anlegen und dort den API-Schlüssel kopieren.
2. Im Terminal **in diesem Ordner** ausführen (Schlüssel einsetzen):
```
claude mcp add pixellab https://api.pixellab.ai/mcp -t http -H "Authorization: Bearer DEIN_SCHLÜSSEL"
```
3. Claude Code neu starten und mit `/mcp` prüfen, ob „pixellab“ verbunden ist.

Der Schlüssel landet so nur in deiner lokalen Konfiguration, nicht in den Projektdateien. Bitte nie in `CLAUDE.md` oder andere Dateien schreiben.
Aktuelle Anleitung von PixelLab: https://www.pixellab.ai/mcp

## Tests
```
cd tests
npm install
npm test
```

## Sprite-Werkzeug (Python)
```
cd tools/sprites
pip install -r requirements.txt
python big.py        # rendert die Feuerfuchs-Linie als Vorschau (linie_big2.png)
python export_big.py # exportiert die großen Sprites
```
