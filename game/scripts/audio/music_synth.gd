class_name MusicSynth
extends RefCounted
## Sequenzer + Synthesizer für die Platzhalter-Musik im Stil der GBA/DS-Ära (Streicher, Blech,
## Glockenspiel, gezupfter Bass, Schlagzeug, Stereo-Echo). Eigene Kompositionen, nur der Stil ist angelehnt.
## Gerendert von tools/render_music.gd nach assets/music/*.wav (Stereo, 32 kHz).
##
## Notation: 16 Schritte = 1 Takt, "-" = Ton halten (auch über Taktgrenzen), "." = Pause.
## Pro Stück: Abschnitte (Intro wird nur einmal gespielt, danach A+B in Schleife).

const RATE := 32000

const NOTE_INDEX := {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6,
	"G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}

const TRACKS := {
	"battle": {
		"bpm": 168, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "x..x..x.........", "drums": "battle", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Am", "E"], "melody": [
				"A4 . A4 . C5 . A4 . D5 . A4 . E5 . D#5 .",
				"E5 - - . E5 - - . G#4 - A4 - B4 - D5 -"]},
			{"name": "A", "chords": ["Am", "F", "G", "Em", "Am", "F", "Dm", "E"], "melody": [
				"E5 - - - A5 - - - G5 - E5 - C5 - D5 -",
				"C5 - - - A4 - - - C5 - F5 - E5 - C5 -",
				"D5 - - - G5 - - - F5 - D5 - B4 - G4 -",
				"B4 - - - - - - - E5 - - - G5 - - -",
				"A5 - - - G5 - A5 - C6 - - - B5 - A5 -",
				"A5 - - - F5 - - - C5 - F5 - A5 - C6 -",
				"D6 - - - C6 - A5 - F5 - - - D5 - F5 -",
				"E5 - - - - - - - G#5 - - - B5 - - -"]},
			{"name": "B", "chords": ["F", "G", "Am", "Am", "F", "G", "A", "E"], "melody": [
				"C5 - F5 - A5 - - - A5 - G5 - F5 - G5 -",
				"B4 - D5 - G5 - - - G5 - F5 - E5 - D5 -",
				"E5 - - - C5 - - - A4 - C5 - E5 - A5 -",
				"G5 - - - - - E5 - - - - - . . . .",
				"F5 - A5 - C6 - - - C6 - A5 - F5 - A5 -",
				"G5 - B5 - D6 - - - D6 - B5 - G5 - B5 -",
				"C#6 - - - - - - - E6 - - - C#6 - - -",
				"B5 - - - G#5 - - - E5 - - - D5 - - -"]},
		],
	},
	"map": {
		"bpm": 124, "loud": 0.17, "lead": "lead_soft", "bass": "bounce", "arp": "arp8", "stabs": "", "drums": "map", "counter": "strings",
		"sections": [
			{"name": "A", "chords": ["G", "D", "Em", "C", "G", "D", "C", "D"], "melody": [
				"D5 - - - B4 - - - D5 - G5 - - - F#5 -",
				"E5 - D5 - - - A4 - - - D5 - F#5 - A5 -",
				"G5 - - - F#5 - E5 - - - B4 - - - E5 -",
				"D5 - - - - - C5 - B4 - - - A4 - - -",
				"B4 - D5 - G5 - - - B5 - - - A5 - G5 -",
				"F#5 - - - E5 - D5 - - - F#5 - A5 - - -",
				"G5 - - - E5 - C5 - - - E5 - G5 - E5 -",
				"F#5 - - - - - - - A5 - - - . . . ."]},
			{"name": "B", "chords": ["C", "D", "Bm", "Em", "Am", "D", "G", "G"], "melody": [
				"E5 - G5 - C6 - - - B5 - A5 - G5 - E5 -",
				"F#5 - A5 - D6 - - - C6 - B5 - A5 - F#5 -",
				"D6 - - - B5 - - - F#5 - - - B5 - - -",
				"G5 - - - - - E5 - - - G5 - B5 - - -",
				"C6 - - - B5 - A5 - - - E5 - - - A5 -",
				"B5 - - - A5 - F#5 - - - D5 - E5 - F#5 -",
				"G5 - - - - - - - D5 - - - G5 - - -",
				"- - - - . . . . D5 - E5 - F#5 - - -"]},
		],
	},
	"title": {
		"bpm": 104, "loud": 0.19, "lead": "brass", "bass": "half", "arp": "arp8", "stabs": "", "drums": "title", "counter": "strings",
		"sections": [
			{"name": "intro", "chords": ["C", "G"], "melody": [
				"G4 - - C5 - - E5 - G5 - - - - - - -",
				"F5 - E5 - D5 - - - G5 - - - . . . ."]},
			{"name": "A", "chords": ["C", "Am", "F", "G", "C", "Em", "F", "G"], "melody": [
				"E5 - - - G5 - - - C6 - - - G5 - - -",
				"A5 - - - - - G5 - E5 - - - C5 - - -",
				"F5 - - - A5 - - - C6 - - - A5 - F5 -",
				"G5 - - - - - - - D5 - - - B4 - - -",
				"E5 - - - G5 - - - C6 - - - E6 - - -",
				"D6 - - - B5 - - - G5 - - - B5 - - -",
				"C6 - - - A5 - F5 - A5 - - - C6 - - -",
				"D6 - - - - - - - - - - - . . . ."]},
			{"name": "B", "chords": ["F", "G", "Em", "Am", "F", "G", "C", "C"], "melody": [
				"A5 - - - G5 - F5 - G5 - - - A5 - - -",
				"B5 - - - A5 - G5 - A5 - - - B5 - - -",
				"G5 - - - E5 - - - B5 - - - G5 - - -",
				"A5 - - - - - - - C6 - - - E6 - - -",
				"F6 - - - E6 - D6 - C6 - - - A5 - - -",
				"D6 - - - C6 - B5 - D6 - - - G5 - - -",
				"C6 - - - - - - - - - - - - - - -",
				". . . . . . . . G5 - A5 - B5 - - -"]},
		],
	},
	"victory": {
		"bpm": 132, "loud": 0.17, "lead": "brass", "bass": "half", "arp": "arp8", "stabs": "", "drums": "map", "counter": "strings",
		"sections": [
			{"name": "intro", "chords": ["C", "G"], "melody": [
				"G4 . C5 . E5 . G5 - - - E5 . G5 - - -",
				"A5 - - - B5 - - - D6 - - - - - - -"]},
			{"name": "A", "chords": ["C", "Am", "F", "G"], "melody": [
				"E5 - - - G5 - - - C6 - - - G5 - - -",
				"A5 - - - E5 - - - C5 - - - E5 - - -",
				"F5 - - - A5 - - - C6 - - - A5 - - -",
				"G5 - - - B5 - - - D6 - - - B5 - - -"]},
		],
	},
	"boss": {
		"bpm": 176, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "x.x...x...x.x...", "drums": "boss", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Dm", "A"], "melody": [
				"D5 . D5 . D5 . . . F5 . F5 . E5 . C#5 .",
				"D5 - - - - - - - A4 - - - C#5 - E5 -"]},
			{"name": "A", "chords": ["Dm", "Bb", "C", "A", "Dm", "Bb", "Gm", "A"], "melody": [
				"D5 - - - A5 - - - G5 - F5 - E5 - D5 -",
				"F5 - - - D5 - - - Bb4 - D5 - F5 - Bb5 -",
				"C6 - - - Bb5 - A5 - G5 - - - E5 - C5 -",
				"C#5 - - - E5 - - - A5 - - - G5 - E5 -",
				"F5 - - - D5 - F5 - A5 - - - D6 - - -",
				"D6 - - - C6 - Bb5 - F5 - - - D5 - F5 -",
				"G5 - - - Bb5 - - - D6 - - - C6 - Bb5 -",
				"A5 - - - - - - - C#6 - - - E6 - - -"]},
			{"name": "B", "chords": ["Bb", "C", "D", "D", "Gm", "A", "Bb", "A"], "melody": [
				"D6 - - - C6 - Bb5 - F5 - - - Bb5 - - -",
				"E6 - - - D6 - C6 - G5 - - - C6 - - -",
				"F#6 - - - - - - - D6 - - - A5 - - -",
				"F#5 - A5 - D6 - F#6 - A6 - - - - - - -",
				"G6 - - - F6 - D6 - Bb5 - - - G5 - - -",
				"A5 - C#6 - E6 - - - G6 - - - E6 - C#6 -",
				"D6 - - - F6 - - - Bb5 - - - D6 - - -",
				"C#6 - - - E6 - - - A6 - - - . . . ."]},
		],
	},
	# ---------- Ebenen-Wächter (30.09.2026): treibend, E-Moll, eigenständig neben der Bossmusik ----------
	"guard": {
		"bpm": 172, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "x..x...x..x.x...", "drums": "guard", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Em", "F"], "melody": [
				"E5 . E5 . G5 . E5 . F5 . . . E5 . D5 .",
				"E5 - - - - - - - B4 - - - D5 - F5 -"]},
			{"name": "A", "chords": ["Em", "C", "D", "B", "Em", "C", "Am", "B"], "melody": [
				"E5 - - - B5 - - - A5 - G5 - F#5 - E5 -",
				"G5 - - - E5 - - - C5 - E5 - G5 - C6 -",
				"A5 - - - F#5 - - - D5 - F#5 - A5 - D6 -",
				"B5 - - - - - - - D#5 - F#5 - B5 - A5 -",
				"G5 - - - E5 - G5 - B5 - - - E6 - - -",
				"E6 - - - D6 - C6 - G5 - - - C6 - - -",
				"A5 - - - C6 - - - E6 - - - D6 - C6 -",
				"B5 - - - - - - - D#6 - - - F#6 - - -"]},
			{"name": "B", "chords": ["C", "D", "Em", "Em", "Am", "B", "C", "B"], "melody": [
				"E6 - - - D6 - C6 - G5 - - - C6 - - -",
				"F#6 - - - E6 - D6 - A5 - - - D6 - - -",
				"G6 - - - - - - - E6 - - - B5 - - -",
				"G5 - B5 - E6 - G6 - B6 - - - - - - -",
				"A6 - - - G6 - E6 - C6 - - - A5 - - -",
				"B5 - D#6 - F#6 - - - A6 - - - F#6 - D#6 -",
				"E6 - - - G6 - - - C6 - - - E6 - - -",
				"D#6 - - - F#6 - - - B6 - - - . . . ."]},
		],
	},
	# ---------- Kino-Intro (30.09.2026): läuft einmal durch, Abschnitte = Bilder des Intros ----------
	# Welt 4 Takte (10 s) · Fehler 3 Takte (7,5 s) · Absturz 1 Takt (2,5 s) · Flucht 3 Takte (7,5 s) · Titel 2 Takte (5 s)
	"opening": {
		"bpm": 96, "loud": 0.15, "lead": "lead_soft", "bass": "half", "arp": "arp8", "stabs": "", "drums": "none", "counter": "strings", "oneshot": true,
		"sections": [
			{"name": "world", "chords": ["C", "Am", "F", "C", "Dm", "G"], "fill": false, "melody": [
				"E5 - - - G5 - - - C6 - - - B5 - G5 -",
				"A5 - - - - - - - E5 - - - C5 - - -",
				"F5 - - - A5 - - - C6 - - - A5 - F5 -",
				"E5 - - - G5 - - - E6 - - - D6 - C6 -",
				"D6 - - - - - - - A5 - - - F5 - - -",
				"G5 - - - - - - - D5 - - - . . . ."]},
			{"name": "corrupt", "chords": ["Am", "Bb", "E"], "lead": "brass", "arp": "none", "drums": "timp_build", "melody": [
				"A4 - - - - - - - C5 - - - B4 - - -",
				"Bb4 - - - - - - - A4 - - - F4 - - -",
				"E4 - - - - - - - G#4 - - - B4 - D5 -"]},
			{"name": "crash", "chords": ["-"], "drums": "hit", "fill": false, "melody": [
				". . . . . . . . . . . . . . . ."]},
			{"name": "flight", "chords": ["Dm", "Bb", "C"], "lead": "brass", "bass": "octave8", "arp": "arp16", "stabs": "x..x..x.........", "drums": "battle", "melody": [
				"D5 . D5 . F5 . D5 . A5 - - - G5 - F5 -",
				"F5 - - - D5 - - - Bb4 - D5 - F5 - Bb5 -",
				"C6 - - - Bb5 - A5 - G5 - E5 - C5 - E5 -"]},
			{"name": "B", "chords": ["F", "C"], "lead": "brass", "arp": "arp8", "drums": "title", "fill": false, "melody": [
				"F5 - - - A5 - - - C6 - - - - - - -",
				"C6 - - - - - - - - - - - - - - -"]},
		],
	},
	# ---------- Opening ----------
	"intro": {
		"bpm": 80, "loud": 0.16, "lead": "lead_soft", "bass": "half", "arp": "arp8", "stabs": "", "drums": "none", "counter": "strings",
		"sections": [
			{"name": "A", "chords": ["Dm", "Bb", "F", "C", "Dm", "Bb", "Gm", "A"], "melody": [
				"A4 - - - D5 - - - F5 - - - E5 - D5 -",
				"D5 - - - - - - - Bb4 - - - C5 - D5 -",
				"C5 - - - F5 - - - A5 - - - G5 - F5 -",
				"E5 - - - - - - - C5 - - - . . . .",
				"A4 - - - D5 - - - F5 - - - A5 - G5 -",
				"F5 - - - D5 - - - Bb4 - - - D5 - F5 -",
				"G5 - - - F5 - - - D5 - - - Bb4 - - -",
				"C#5 - - - - - - - E5 - - - . . . ."]},
			{"name": "B", "chords": ["Bb", "C", "F", "Dm", "Bb", "C", "F", "F"], "melody": [
				"D5 - - - F5 - - - Bb5 - - - A5 - G5 -",
				"E5 - - - G5 - - - C6 - - - Bb5 - A5 -",
				"A5 - - - - - - - F5 - - - C5 - F5 -",
				"D5 - - - - - - - . . . . A4 - D5 -",
				"F5 - - - Bb5 - - - D6 - - - C6 - Bb5 -",
				"A5 - - - G5 - - - E5 - - - G5 - - -",
				"F5 - - - - - - - - - - - . . . .",
				". . . . . . . . C5 - D5 - E5 - - -"]},
		],
	},
	# ---------- Zone 2: Firewall-Vulkan ----------
	"map_vulkan": {
		"bpm": 108, "loud": 0.18, "lead": "brass", "bass": "half", "arp": "arp8", "stabs": "", "drums": "vulkan_map", "counter": "strings",
		"sections": [
			{"name": "A", "chords": ["Em", "C", "D", "Bm", "Em", "C", "Am", "B"], "melody": [
				"E5 - - - G5 - - - B5 - - - A5 - G5 -",
				"E5 - - - - - - - C5 - D5 - E5 - G5 -",
				"F#5 - - - A5 - - - D6 - - - C6 - A5 -",
				"B5 - - - - - - - F#5 - - - D5 - - -",
				"E5 - G5 - B5 - - - E6 - - - D6 - B5 -",
				"C6 - - - B5 - G5 - E5 - - - G5 - C6 -",
				"A5 - - - C6 - B5 - A5 - - - E5 - - -",
				"D#5 - - - F#5 - - - B5 - - - . . . ."]},
			{"name": "B", "chords": ["C", "D", "Em", "Em", "Am", "B", "Em", "Em"], "melody": [
				"G5 - - - E5 - - - C5 - - - E5 - G5 -",
				"A5 - - - F#5 - - - D5 - - - F#5 - A5 -",
				"B5 - - - - - - - G5 - - - E5 - - -",
				"B4 - - - E5 - G5 - B5 - - - - - - -",
				"C6 - - - B5 - A5 - E5 - - - A5 - - -",
				"B5 - - - A5 - F#5 - D#5 - - - F#5 - - -",
				"E5 - - - - - - - - - - - . . . .",
				". . . . . . . . B4 - D5 - E5 - F#5 -"]},
		],
	},
	"battle_vulkan": {
		"bpm": 172, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "x..x..x...x.x...", "drums": "vulkan", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Cm", "G"], "melody": [
				"C5 . C5 . Eb5 . C5 . G5 . C5 . Ab5 . G5 .",
				"G5 - - . G5 - - . B4 - C5 - D5 - F5 -"]},
			{"name": "A", "chords": ["Cm", "Ab", "Bb", "G", "Cm", "Ab", "Fm", "G"], "melody": [
				"G5 - - - C6 - - - Bb5 - G5 - Eb5 - F5 -",
				"Ab5 - - - Eb5 - - - C5 - Eb5 - Ab5 - C6 -",
				"Bb5 - - - F5 - - - D5 - F5 - Bb5 - D6 -",
				"B5 - - - - - - - G5 - - - D5 - - -",
				"C6 - - - Eb6 - D6 - C6 - - - G5 - - -",
				"Ab5 - - - C6 - Eb6 - - - C6 - Ab5 - - -",
				"F5 - Ab5 - C6 - - - F6 - - - Eb6 - C6 -",
				"D6 - - - - - - - B5 - - - G5 - - -"]},
			{"name": "B", "chords": ["Ab", "Bb", "Eb", "Cm", "Fm", "G", "Ab", "G"], "melody": [
				"C6 - - - Ab5 - - - Eb5 - Ab5 - C6 - - -",
				"D6 - - - Bb5 - - - F5 - Bb5 - D6 - - -",
				"Eb6 - - - - - - - G5 - Bb5 - Eb6 - G6 -",
				"G6 - - - F6 - Eb6 - C6 - - - G5 - - -",
				"F6 - - - Eb6 - C6 - Ab5 - - - C6 - F6 -",
				"G6 - - - - - - - D6 - - - B5 - D6 -",
				"Eb6 - - - C6 - Ab5 - Eb6 - - - Ab6 - - -",
				"G6 - - - - - - - B5 - D6 - F6 - - -"]},
		],
	},
	# ---------- Zone 3: Viren-Sümpfe ----------
	"map_sumpf": {
		"bpm": 96, "loud": 0.17, "lead": "lead_soft", "bass": "bounce", "arp": "offbeat", "stabs": "", "drums": "sumpf_map", "counter": "strings",
		"sections": [
			{"name": "A", "chords": ["Dm", "Dm", "Bb", "A", "Dm", "F", "Gm", "A"], "melody": [
				"D5 - - . F5 - A5 - G5 - F5 - E5 - F5 -",
				"D5 - - - - - - - A4 - - - D5 - E5 -",
				"F5 - - . D5 - Bb4 - D5 - F5 - Bb5 - A5 -",
				"A5 - - - G5 - E5 - C#5 - - - A4 - - -",
				"D5 - - . F5 - A5 - D6 - - - C6 - A5 -",
				"C6 - - - A5 - F5 - C5 - - - F5 - A5 -",
				"Bb5 - - - A5 - G5 - D5 - - - G5 - Bb5 -",
				"A5 - - - - - - - E5 - - - C#5 - - -"]},
			{"name": "B", "chords": ["Gm", "C", "F", "Dm", "Bb", "Gm", "A", "A"], "melody": [
				"G5 - - - Bb5 - - - D6 - - - Bb5 - G5 -",
				"E5 - - - G5 - - - C6 - - - Bb5 - G5 -",
				"A5 - - - F5 - - - C5 - - - F5 - A5 -",
				"D6 - - - - - A5 - F5 - - - D5 - - -",
				"D5 - F5 - Bb5 - - - A5 - G5 - F5 - D5 -",
				"G5 - - - Bb5 - D6 - - - Bb5 - G5 - - -",
				"A5 - - - C#6 - - - E6 - - - C#6 - - -",
				"A5 - - - - - - - . . . . A4 - C#5 -"]},
		],
	},
	"battle_sumpf": {
		"bpm": 160, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "..x...x...x...x.", "drums": "sumpf", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Gm", "D"], "melody": [
				"G4 . Bb4 . D5 . G5 . F#5 . D5 . A4 . F#4 .",
				"G4 - - - Bb4 - - - A4 - - - D5 - - -"]},
			{"name": "A", "chords": ["Gm", "Eb", "F", "D", "Gm", "Eb", "Cm", "D"], "melody": [
				"D5 - G5 - Bb5 - - - A5 - G5 - F#5 - G5 -",
				"G5 - - - Eb5 - - - Bb4 - Eb5 - G5 - Bb5 -",
				"A5 - - - F5 - - - C5 - F5 - A5 - C6 -",
				"A5 - - - - - - - F#5 - - - D5 - - -",
				"G5 . G5 . Bb5 . G5 . D6 - - - C6 - Bb5 -",
				"Bb5 - - - G5 - Eb5 - G5 - - - Bb5 - Eb6 -",
				"D6 - - - C6 - - - G5 - C6 - Eb6 - - -",
				"D6 - - - - - - - F#5 - - - A5 - - -"]},
			{"name": "B", "chords": ["Eb", "F", "Dm", "Gm", "Cm", "D", "Eb", "D"], "melody": [
				"G5 - - - Bb5 - Eb6 - - - Bb5 - G5 - - -",
				"A5 - - - C6 - F6 - - - C6 - A5 - - -",
				"F5 - - - A5 - D6 - - - A5 - F5 - D5 -",
				"G5 - - - - - - - Bb5 - - - D6 - - -",
				"Eb6 - - - D6 - C6 - G5 - - - C6 - Eb6 -",
				"D6 - - - C6 - A5 - F#5 - - - A5 - D6 -",
				"Eb6 - - - - - Bb5 - G5 - - - Bb5 - Eb6 -",
				"D6 - - - - - - - A5 - C6 - F#6 - - -"]},
		],
	},
	# ---------- Kühlwasser-See (06.10.2026): ruhig, fließend, e-Moll ----------
	"map_see": {
		"bpm": 92, "loud": 0.17, "lead": "lead_soft", "bass": "half", "arp": "arp16", "stabs": "", "drums": "see_map", "counter": "strings",
		"sections": [
			{"name": "A", "chords": ["Em", "C", "G", "D", "Em", "C", "Am", "B"], "melody": [
				"E5 - - - G5 - B5 - A5 - G5 - F#5 - E5 -",
				"G5 - - - - - E5 - C5 - - - E5 - G5 -",
				"B5 - - - A5 - G5 - D5 - - - G5 - B5 -",
				"A5 - - - - - - - F#5 - - - D5 - - -",
				"E5 - - - B5 - - - A5 - G5 - E5 - G5 -",
				"C6 - - - B5 - G5 - E5 - - - G5 - C6 -",
				"B5 - - - A5 - E5 - C5 - - - E5 - A5 -",
				"B5 - - - - - - - D#5 - - - F#5 - - -"]},
			{"name": "B", "chords": ["C", "D", "Bm", "Em", "Am", "D", "C", "B"], "melody": [
				"G5 - - - E5 - - - C6 - - - B5 - G5 -",
				"A5 - - - F#5 - - - D6 - - - C6 - A5 -",
				"B5 - - - - - F#5 - D5 - - - F#5 - B5 -",
				"G5 - - - - - E5 - B4 - - - E5 - - -",
				"E5 - A5 - C6 - - - B5 - A5 - E5 - - -",
				"F#5 - A5 - D6 - - - C6 - A5 - F#5 - - -",
				"G5 - - - E5 - G5 - C6 - - - B5 - A5 -",
				"B5 - - - - - - - . . . . F#5 - D#5 -"]},
		],
	},
	"battle_see": {
		"bpm": 166, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "x.....x...x.....", "drums": "see", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Am", "E"], "melody": [
				"A4 . C5 . E5 . A5 . G#5 . E5 . B4 . G#4 .",
				"A4 - - - C5 - - - B4 - - - E5 - - -"]},
			{"name": "A", "chords": ["Am", "F", "G", "E", "Am", "F", "Dm", "E"], "melody": [
				"E5 - A5 - C6 - - - B5 - A5 - G#5 - A5 -",
				"A5 - - - F5 - - - C5 - F5 - A5 - C6 -",
				"B5 - - - G5 - - - D5 - G5 - B5 - D6 -",
				"B5 - - - - - - - G#5 - - - E5 - - -",
				"A5 . A5 . C6 . A5 . E6 - - - D6 - C6 -",
				"C6 - - - A5 - F5 - A5 - - - C6 - F6 -",
				"D6 - - - C6 - - - A5 - D6 - F6 - - -",
				"E6 - - - - - - - G#5 - - - B5 - - -"]},
			{"name": "B", "chords": ["F", "G", "Em", "Am", "Dm", "E", "F", "E"], "melody": [
				"A5 - - - C6 - F6 - - - C6 - A5 - - -",
				"B5 - - - D6 - G6 - - - D6 - B5 - - -",
				"G5 - - - B5 - E6 - - - B5 - G5 - E5 -",
				"A5 - - - - - - - C6 - - - E6 - - -",
				"F6 - - - E6 - D6 - A5 - - - D6 - F6 -",
				"E6 - - - - - - - G#5 - - - B5 - D6 -",
				"C6 - - - A5 - F5 - C6 - - - F6 - - -",
				"E6 - - - - - - - B5 - D6 - G#6 - - -"]},
		],
	},
	# ---------- Hochspannungs-Steppe (06.10.2026): weit, heldenhaft, D-Dur ----------
	"map_steppe": {
		"bpm": 112, "loud": 0.18, "lead": "brass", "bass": "bounce", "arp": "arp8", "stabs": "", "drums": "steppe_map", "counter": "strings",
		"sections": [
			{"name": "A", "chords": ["D", "C", "G", "D", "D", "C", "G", "A"], "melody": [
				"D5 - - - F#5 - A5 - - - F#5 - A5 - D6 -",
				"C6 - - - - - G5 - E5 - - - G5 - C6 -",
				"B5 - - - A5 - G5 - D5 - - - G5 - B5 -",
				"A5 - - - - - - - F#5 - - - D5 - - -",
				"D6 - - - C6 - A5 - F#5 - A5 - D6 - - -",
				"E6 - - - D6 - C6 - G5 - - - C6 - E6 -",
				"D6 - - - B5 - G5 - B5 - - - D6 - G6 -",
				"E6 - - - - - - - C#6 - - - A5 - - -"]},
			{"name": "B", "chords": ["Bm", "G", "D", "A", "Bm", "G", "Em", "A"], "melody": [
				"F#5 - - - B5 - - - D6 - - - C#6 - B5 -",
				"G5 - - - B5 - - - D6 - - - B5 - G5 -",
				"A5 - - - F#5 - - - D5 - - - F#5 - A5 -",
				"E5 - - - - - - - A5 - - - C#6 - - -",
				"D6 - - - C#6 - B5 - F#5 - - - B5 - D6 -",
				"D6 - - - B5 - G5 - D5 - - - G5 - B5 -",
				"E6 - - - D6 - B5 - G5 - - - B5 - E6 -",
				"C#6 - - - - - - - . . . . A5 - C#6 -"]},
		],
	},
	"battle_steppe": {
		"bpm": 176, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "x.x...x.x.x...x.", "drums": "steppe", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Bm", "F#"], "melody": [
				"B4 . D5 . F#5 . B5 . A#5 . F#5 . C#5 . A#4 .",
				"B4 - - - D5 - - - C#5 - - - F#5 - - -"]},
			{"name": "A", "chords": ["Bm", "G", "A", "F#", "Bm", "G", "Em", "F#"], "melody": [
				"F#5 - B5 - D6 - - - C#6 - B5 - A#5 - B5 -",
				"B5 - - - G5 - - - D5 - G5 - B5 - D6 -",
				"C#6 - - - A5 - - - E5 - A5 - C#6 - E6 -",
				"C#6 - - - - - - - A#5 - - - F#5 - - -",
				"B5 . B5 . D6 . B5 . F#6 - - - E6 - D6 -",
				"D6 - - - B5 - G5 - B5 - - - D6 - G6 -",
				"E6 - - - D6 - - - B5 - E6 - G6 - - -",
				"F#6 - - - - - - - A#5 - - - C#6 - - -"]},
			{"name": "B", "chords": ["G", "A", "D", "Bm", "Em", "F#", "G", "F#"], "melody": [
				"B5 - - - D6 - G6 - - - D6 - B5 - - -",
				"C#6 - - - E6 - A6 - - - E6 - C#6 - - -",
				"A5 - - - D6 - F#6 - - - D6 - A5 - F#5 -",
				"B5 - - - - - - - D6 - - - F#6 - - -",
				"G6 - - - F#6 - E6 - B5 - - - E6 - G6 -",
				"F#6 - - - - - - - A#5 - - - C#6 - E6 -",
				"D6 - - - B5 - G5 - D6 - - - G6 - - -",
				"F#6 - - - - - - - C#6 - E6 - A#6 - - -"]},
		],
	},
	# ---------- Finale: NEST-Kern ----------
	"map_kern": {
		"bpm": 100, "loud": 0.17, "lead": "lead_soft", "bass": "bounce", "arp": "arp16", "stabs": "", "drums": "map", "counter": "strings",
		"sections": [
			{"name": "A", "chords": ["Cm", "Ab", "Eb", "Bb", "Cm", "Ab", "Fm", "G"], "melody": [
				"G5 - - - Eb5 - - - C5 - - - D5 - Eb5 -",
				"C5 - - - - - - - Ab4 - - - C5 - Eb5 -",
				"Bb4 - - - Eb5 - - - G5 - - - F5 - Eb5 -",
				"D5 - - - - - - - F5 - - - . . . .",
				"G5 - - - C6 - - - Bb5 - - - G5 - Eb5 -",
				"Eb5 - - - Ab5 - - - C6 - - - Ab5 - F5 -",
				"F5 - - - Ab5 - - - C6 - - - Bb5 - Ab5 -",
				"G5 - - - - - - - B4 - - - D5 - - -"]},
			{"name": "B", "chords": ["Ab", "Bb", "Gm", "Cm", "Ab", "Bb", "G", "G"], "melody": [
				"C6 - - - Bb5 - Ab5 - Eb5 - - - Ab5 - - -",
				"D6 - - - C6 - Bb5 - F5 - - - Bb5 - - -",
				"Bb5 - - - G5 - - - D5 - - - G5 - Bb5 -",
				"C6 - - - - - - - G5 - - - Eb5 - - -",
				"Eb6 - - - D6 - C6 - Ab5 - - - C6 - Eb6 -",
				"D6 - - - F6 - - - Bb5 - - - D6 - - -",
				"B5 - - - D6 - - - G6 - - - F6 - D6 -",
				"B5 - - - - - - - . . . . D5 - F5 -"]},
		],
	},
	"finale": {
		"bpm": 184, "loud": 0.21, "lead": "lead_sq", "bass": "octave8", "arp": "arp16", "stabs": "x.x...x...x.x...", "drums": "boss", "counter": "brass",
		"sections": [
			{"name": "intro", "chords": ["Em", "B"], "melody": [
				"E5 . E5 . G5 . E5 . B5 . A5 . G5 . F#5 .",
				"E5 - - - - - - - D#5 - - - F#5 - B5 -"]},
			{"name": "A", "chords": ["Em", "C", "D", "B", "Em", "C", "Am", "B"], "melody": [
				"E5 - - - B5 - - - A5 - G5 - F#5 - E5 -",
				"G5 - - - E5 - - - C5 - E5 - G5 - C6 -",
				"D6 - - - C6 - B5 - A5 - - - F#5 - D5 -",
				"D#5 - - - F#5 - - - B5 - - - A5 - F#5 -",
				"G5 - - - E5 - G5 - B5 - - - E6 - - -",
				"E6 - - - D6 - C6 - G5 - - - E5 - G5 -",
				"A5 - - - C6 - - - E6 - - - D6 - C6 -",
				"B5 - - - - - - - D#6 - - - F#6 - - -"]},
			{"name": "B", "chords": ["C", "D", "Em", "Em", "Am", "B", "C", "B"], "melody": [
				"E6 - - - D6 - C6 - G5 - - - C6 - - -",
				"F#6 - - - E6 - D6 - A5 - - - D6 - - -",
				"G6 - - - - - - - E6 - - - B5 - - -",
				"G5 - B5 - E6 - G6 - B6 - - - - - - -",
				"A6 - - - G6 - E6 - C6 - - - A5 - - -",
				"B5 - D#6 - F#6 - - - A6 - - - F#6 - D#6 -",
				"E6 - - - G6 - - - C6 - - - E6 - - -",
				"D#6 - - - F#6 - - - B6 - - - . . . ."]},
		],
	},
	# ---------- Kino-Ende (30.09.2026): läuft einmal durch, Abschnitte = Bilder des Endes (96 BPM, 1 Takt = 2,5 s) ----------
	# Heilung 4 Takte · Heimkehr 3 · Team 3 · Zimmer 3 · Titel 2 · Abspann 6 · Ende 3
	"ending": {
		"bpm": 96, "loud": 0.17, "lead": "lead_soft", "bass": "half", "arp": "arp8", "stabs": "", "drums": "none", "counter": "strings", "oneshot": true,
		"sections": [
			{"name": "heal", "chords": ["C", "Am", "F", "G"], "fill": false, "melody": [
				"E5 - - - G5 - - - C6 - - - B5 - G5 -",
				"A5 - - - - - - - E5 - - - C5 - - -",
				"F5 - - - A5 - - - C6 - - - F6 - E6 -",
				"D6 - - - - - - - B5 - - - G5 - - -"]},
			{"name": "return", "chords": ["F", "Bb", "C"], "lead": "brass", "bass": "octave8", "arp": "arp16", "stabs": "x..x..x.........", "drums": "map", "melody": [
				"F5 . F5 . A5 . F5 . C6 - - - Bb5 - A5 -",
				"Bb5 - - - F5 - - - D5 - F5 - Bb5 - D6 -",
				"C6 - - - - - - - E5 - G5 - C6 - E6 -"]},
			{"name": "B", "chords": ["F", "C", "Dm"], "lead": "brass", "drums": "title", "melody": [
				"A5 - - - C6 - - - F6 - - - E6 - C6 -",
				"E6 - - - D6 - C6 - G5 - - - C6 - - -",
				"D6 - - - F6 - - - A6 - - - F6 - D6 -"]},
			{"name": "room", "chords": ["Bb", "F", "C"], "fill": false, "melody": [
				"D5 - - - F5 - - - Bb5 - - - A5 - G5 -",
				"A5 - - - - - - - F5 - - - C5 - - -",
				"E5 - - - G5 - - - C6 - - - . . . ."]},
			{"name": "title", "chords": ["F", "F"], "lead": "brass", "drums": "hit", "fill": false, "melody": [
				"F5 - - - A5 - - - C6 - - - - - - -",
				"F6 - - - - - - - - - - - - - - -"]},
			{"name": "B", "chords": ["Bb", "C", "F", "Dm", "Bb", "C"], "lead": "brass", "drums": "title", "melody": [
				"D5 - - - F5 - - - Bb5 - - - A5 - G5 -",
				"E5 - - - G5 - - - C6 - - - Bb5 - A5 -",
				"A5 - - - - - - - F5 - - - C5 - F5 -",
				"D5 - - - - - - - . . . . A4 - D5 -",
				"F5 - - - Bb5 - - - D6 - - - C6 - Bb5 -",
				"A5 - - - G5 - - - E5 - - - G5 - - -"]},
			{"name": "end", "chords": ["F", "Bb", "F"], "lead": "brass", "drums": "hit", "fill": false, "melody": [
				"A5 - - - - - - - F5 - - - C5 - F5 -",
				"D6 - - - - - - - Bb5 - - - F5 - - -",
				"F5 - - - - - - - - - - - - - - -"]},
		],
	},
	# ---------- Epische Fassungen (08.10.2026, Wunsch Produzent: „epische Musik“) ----------
	# Eigene Kompositionen. Neu im Klang: Chor („choir“), Streicher-Ostinato („ostinato“), Melodie eine Oktave tiefer
	# gedoppelt („double“), zweite Lead-Stimme („lead2“), Taiko-Pauken. Die alten Stücke bleiben als Dateien erhalten.
	# Leitmotiv: Quinte–Grundton–Terz–Quinte (Titel: A4 D5 F#5 A5), die Station zitiert es ruhig in F-Dur.
	"title_epic": {
		"bpm": 96, "loud": 0.19, "lead": "brass", "bass": "half", "arp": "ostinato", "stabs": "", "drums": "epic_title", "counter": "strings",
		"choir": 0.8, "double": "strings",
		"sections": [
			{"name": "intro", "chords": ["D", "C", "G", "A"], "drums": "timp_build", "arp": "", "melody": [
				"D5 - - - - - - - - - - - A4 - D5 -",
				"E5 - - - - - - - - - - - G5 - E5 -",
				"D5 - - - - - - - B4 - - - D5 - G5 -",
				"A5 - - - - - - - - - - - . . . ."]},
			{"name": "A", "chords": ["D", "Bm", "G", "A", "D", "F#m", "G", "A"], "melody": [
				"A4 - D5 - - - F#5 - A5 - - - - - - -",
				"B5 - A5 - F#5 - - - D5 - - - F#5 - - -",
				"G5 - - - B5 - - - D6 - - - B5 - G5 -",
				"A5 - - - - - - - E5 - - - C#6 - - -",
				"A4 - D5 - - - F#5 - A5 - - - D6 - - -",
				"C#6 - - - A5 - F#5 - - - C#5 - F#5 - A5 -",
				"B5 - - - D6 - - - G6 - - - F#6 - E6 -",
				"E6 - - - - - - - C#6 - - - A5 - - -"]},
			{"name": "B", "chords": ["Bm", "G", "D", "A", "Bm", "G", "Em", "A"], "melody": [
				"F#5 - - - B5 - - - D6 - - - C#6 - B5 -",
				"B5 - - - G5 - - - D5 - - - G5 - B5 -",
				"A5 - - - F#5 - - - D5 - - - A5 - - -",
				"C#6 - - - - - - - E6 - - - - - - -",
				"D6 - - - C#6 - B5 - F#5 - - - B5 - D6 -",
				"E6 - - - D6 - B5 - G5 - - - D6 - E6 -",
				"G6 - - - F#6 - E6 - B5 - - - E6 - G6 -",
				"E6 - - - - - - - C#6 - - - A5 - - -"]},
			# Aufschwung (08.10.2026 überarbeitet, vorher ruhiger Flötenteil – Produzent: „nicht so toll“):
			# lange, steigende Blechbögen über Taikos und vollem Chor, B-Dur als geliehener Akkord vor der Rückkehr
			{"name": "C", "chords": ["G", "A", "F#m", "Bm", "G", "A", "Bb", "A"], "drums": "taiko", "choir": 1.0, "melody": [
				"D5 - - - - - - - G5 - - - B5 - - -",
				"C#6 - - - - - - - A5 - - - E5 - - -",
				"F#5 - - - - - - - A5 - - - C#6 - - -",
				"D6 - - - - - - - B5 - - - F#5 - - -",
				"G5 - - - B5 - - - D6 - - - G6 - - -",
				"E6 - - - - - - - C#6 - - - A5 - - -",
				"F6 - - - - - - - D6 - - - Bb5 - - -",
				"A5 - - - C#6 - - - E6 - - - - - - -"]},
		],
	},
	"station": {
		"bpm": 84, "loud": 0.15, "lead": "lead_soft", "bass": "half", "arp": "arp8", "stabs": "", "drums": "home", "counter": "strings",
		"choir": 0.25,
		"sections": [
			{"name": "A", "chords": ["F", "Dm", "Bb", "C", "F", "Am", "Bb", "C"], "melody": [
				"C5 - F5 - - - A5 - C6 - - - - - - -",
				"D6 - C6 - A5 - - - F5 - - - - - - -",
				"D5 - - - F5 - - - Bb5 - - - A5 - G5 -",
				"G5 - - - - - - - - - - - E5 - - -",
				"C5 - F5 - - - A5 - C6 - - - D6 - - -",
				"E6 - - - C6 - A5 - - - E5 - - - A5 -",
				"D6 - - - Bb5 - - - F5 - - - G5 - A5 -",
				"G5 - - - - - - - - - - - . . . ."]},
			{"name": "B", "chords": ["Bb", "C", "Am", "Dm", "Gm", "C", "F", "F"], "melody": [
				"F5 - - - Bb5 - - - D6 - - - C6 - Bb5 -",
				"C6 - - - - - - - G5 - - - - - - -",
				"A5 - - - C6 - - - E6 - - - D6 - C6 -",
				"D6 - - - - - - - A5 - - - - - - -",
				"Bb5 - - - A5 - - - G5 - - - D5 - - -",
				"E5 - - - G5 - - - C6 - - - Bb5 - - -",
				"A5 - - - - - - - - - - - - - - -",
				". . . . . . . . A4 - Bb4 - B4 - - -"]},
		],
	},
	"battle_epic": {
		"bpm": 160, "loud": 0.21, "lead": "brass", "lead2": "lead_sq", "bass": "octave8", "arp": "ostinato", "stabs": "x..x..x.........",
		"drums": "epic_battle", "counter": "brass", "choir": 0.5, "glock": false,
		"sections": [
			{"name": "intro", "chords": ["Em", "B"], "melody": [
				"E5 . E5 . G5 . E5 . B5 - - - A5 . G5 .",
				"F#5 - - - - - - - D#5 - - - B4 - - -"]},
			{"name": "A", "chords": ["Em", "C", "D", "B", "Em", "C", "Am", "B"], "melody": [
				"E5 - - - B4 - - - E5 - G5 - B5 - - -",
				"C6 - - - B5 - A5 - G5 - - - E5 - - -",
				"F#5 - - - A5 - - - D6 - - - C6 - B5 -",
				"B5 - - - - - - - D#5 - - - F#5 - - -",
				"G5 - - - E5 - G5 - B5 - - - E6 - - -",
				"E6 - - - D6 - C6 - G5 - - - C6 - - -",
				"A5 - - - C6 - - - E6 - - - D6 - C6 -",
				"B5 - - - - - - - F#5 - - - D#6 - - -"]},
			{"name": "B", "chords": ["C", "D", "Em", "Em", "Am", "B", "C", "B"], "melody": [
				"G5 - - - C6 - - - E6 - - - - - D6 -",
				"F#6 - - - - - - - E6 - D6 - A5 - - -",
				"G6 - - - - - - - E6 - - - B5 - - -",
				"E6 - - - D6 - B5 - G5 - - - . . . .",
				"A5 - - - G5 - E5 - C6 - - - E6 - - -",
				"F#5 - - - D#6 - - - B5 - - - D#6 - F#6 -",
				"G6 - - - E6 - - - C6 - - - G5 - C6 -",
				"B5 - - - - - - - D#6 - - - F#6 - - -"]},
			# Mittelteil: nur Taikos, Chor schwillt an, Blech in langen Bögen (F-Dur = phrygische Wendung, dramatisch)
			{"name": "C", "chords": ["Am", "Em", "C", "B", "Am", "Em", "F", "B"], "drums": "taiko", "stabs": "", "lead2": "", "choir": 0.9, "melody": [
				"A5 - - - - - - - C6 - - - E6 - - -",
				"E6 - - - - - - - B5 - - - G5 - - -",
				"G5 - - - - - - - C6 - - - E6 - - -",
				"D#6 - - - - - - - F#6 - - - B5 - - -",
				"C6 - - - - - - - E6 - - - A6 - - -",
				"G6 - - - - - - - E6 - - - B5 - - -",
				"A5 - - - C6 - - - F6 - - - E6 - - -",
				"D#6 - - - - - - - F#5 - - - B5 - - -"]},
		],
	},
	"boss_epic": {
		"bpm": 170, "loud": 0.21, "lead": "lead_sq", "lead2": "brass", "bass": "octave8", "arp": "ostinato", "stabs": "x.x...x...x.x...",
		"drums": "epic_boss", "counter": "brass", "choir": 0.9, "double": "strings", "glock": false,
		"sections": [
			{"name": "intro", "chords": ["Cm", "Cm", "Ab", "G"], "drums": "timp_build", "arp": "", "stabs": "", "melody": [
				"C5 - - - - - - - - - - - - - - -",
				"Eb5 - - - - - - - D5 - - - - - - -",
				"C5 - - - - - - - Ab4 - - - - - - -",
				"G4 - - - - - - - B4 - - - D5 - G5 -"]},
			{"name": "A", "chords": ["Cm", "Ab", "Fm", "G", "Cm", "Ab", "Db", "G"], "melody": [
				"C5 - - - G5 - - - Eb5 - D5 - C5 - G4 -",
				"Ab4 - - - C5 - - - Eb5 - - - Ab5 - G5 -",
				"F5 - - - Ab5 - - - C6 - - - Bb5 - Ab5 -",
				"G5 - - - - - - - B4 - - - D5 - F5 -",
				"Eb5 - - - - - C5 - G5 - - - C6 - - -",
				"C6 - - - Bb5 - Ab5 - Eb5 - - - Ab5 - C6 -",
				"Db6 - - - C6 - Ab5 - F5 - - - Ab5 - Db6 -",
				"B5 - - - - - - - D6 - - - G6 - - -"]},
			{"name": "B", "chords": ["Ab", "Bb", "Cm", "Cm", "Fm", "G", "Ab", "G"], "melody": [
				"Eb6 - - - - - - - C6 - - - Ab5 - - -",
				"D6 - - - - - - - Bb5 - - - F5 - - -",
				"G5 - - - C6 - - - Eb6 - - - G6 - - -",
				"G6 - - - F6 - Eb6 - D6 - - - C6 - - -",
				"Ab6 - - - G6 - F6 - C6 - - - F6 - - -",
				"G6 - - - - - - - D6 - - - B5 - - -",
				"C6 - - - Eb6 - - - Ab6 - - - G6 - F6 -",
				"G6 - - - - - - - B5 - - - D6 - - -"]},
			# Mittelteil: Chor-Choral über Taikos, das Blech übernimmt die Melodie
			{"name": "C", "chords": ["Fm", "Cm", "Db", "G", "Fm", "Cm", "Ab", "G"], "drums": "taiko", "stabs": "", "lead": "brass", "lead2": "", "choir": 1.1, "melody": [
				"C6 - - - - - - - Ab5 - - - F5 - - -",
				"G5 - - - - - - - Eb5 - - - C5 - - -",
				"Db6 - - - - - - - F6 - - - Ab5 - - -",
				"B5 - - - - - - - D6 - - - G6 - - -",
				"Ab6 - - - - - - - F6 - - - C6 - - -",
				"G6 - - - - - - - Eb6 - - - C6 - - -",
				"Eb6 - - - - - - - C6 - - - Ab5 - - -",
				"G5 - - - B5 - - - D6 - - - F6 - - -"]},
		],
	},
	# ---------- Trailer (09.10.2026) ----------
	# 36 Takte à 2 s (120 BPM) = 72 s, taktgenau zu den Schnitten in trailer_view.gd. Jeder Abschnitt ein Teil des Trailers:
	# Welt > Korruption > Ei (Herzschlag) > Drop mit Kämpfen > Evolution > Station > Aufbau > Bosse > Logo.
	"trailer": {
		"bpm": 120, "loud": 0.2, "lead": "brass", "bass": "half", "arp": "", "stabs": "", "drums": "none", "counter": "strings", "oneshot": true,
		"choir": 0.6, "double": "strings", "glock": false,
		"sections": [
			{"name": "nest", "gain": 0.3, "chords": ["Dm", "Bb"], "lead": "", "fill": false, "melody": [
				"A5 - - - - - - - D6 - - - E6 - F6 -",
				"D6 - - - - - - - - - - - . . . ."]},
			{"name": "corrupt", "gain": 0.55, "chords": ["Gm", "A"], "drums": "timp_build", "choir": 0.9, "fill": false, "melody": [
				"D5 - - - - - - - Bb4 - - - - - - -",
				"A4 - - - C#5 - - - E5 - - - A5 - - -"]},
			{"name": "egg", "gain": 0.42, "chords": ["Dm", "Dm"], "drums": "heart", "lead": "", "double": "", "choir": 0.5, "melody": [
				". . . . . . . . . . . . . . . .",
				". . . . . . . . . . . . . . . ."]},
			{"name": "drop", "gain": 1, "chords": ["Dm", "Bb", "F", "C", "Dm", "Bb", "Gm", "A"], "drums": "epic_battle", "bass": "octave8", "arp": "ostinato",
				"lead2": "lead_sq", "choir": 0.8, "stabs": "x.....x...x.....", "melody": [
				"D5 - - - A5 - - - F5 - E5 - D5 - A4 -",
				"Bb4 - - - D5 - - - F5 - - - Bb5 - A5 -",
				"A5 - - - F5 - - - C6 - - - A5 - F5 -",
				"G5 - - - - - - - E5 - - - C5 - E5 -",
				"D5 - - - A5 - - - D6 - - - C6 - A5 -",
				"Bb5 - - - A5 - F5 - D5 - - - F5 - Bb5 -",
				"D6 - - - C6 - Bb5 - G5 - - - Bb5 - D6 -",
				"C#6 - - - - - - - E6 - - - A5 - - -"]},
			# Evolution: kurz nur Chor und Streicher-Ostinato, dann die Enthüllung mit Pauken im halben Takt
			{"name": "evo_hold", "gain": 0.55, "chords": ["Bb"], "arp": "ostinato", "choir": 1.1, "fill": false, "melody": [
				"F5 - - - - - - - - - - - G5 - A5 -"]},
			{"name": "evolve", "gain": 0.85, "chords": ["F", "C", "Dm", "Bb", "A"], "drums": "epic_title", "bass": "octave8", "arp": "ostinato", "choir": 1.0, "melody": [
				"A5 - - - - - - - C6 - - - F6 - - -",
				"E6 - - - - - - - G5 - - - C6 - - -",
				"D6 - - - - - - - F5 - - - A5 - D6 -",
				"F6 - - - - - - - D6 - - - Bb5 - - -",
				"C#6 - - - E6 - - - A6 - - - - - - -"]},
			# Station: hell und hüpfend (Zuhause, Labor, Legendäre)
			{"name": "life", "gain": 0.72, "chords": ["F", "C", "Bb", "C"], "drums": "title", "bass": "bounce", "arp": "arp8", "double": "", "choir": 0.5, "fill": false, "melody": [
				"F5 - A5 - C6 - - - A5 - G5 - F5 - - -",
				"E5 - G5 - C6 - - - - - - - G5 - - -",
				"D5 - F5 - Bb5 - - - D6 - C6 - Bb5 - - -",
				"C6 - - - - - - - E5 - - - G5 - - -"]},
			{"name": "build", "gain": 0.8, "chords": ["Gm", "A"], "drums": "timp_build", "bass": "octave8", "arp": "arp16", "choir": 0.9, "melody": [
				"G5 - - - Bb5 - - - D6 - - - G6 - - -",
				"A5 - - - - - - - C#6 - - - E6 - - -"]},
			{"name": "bosses", "gain": 1.12, "chords": ["Dm", "Bb", "Gm", "A", "Bb", "A"], "drums": "epic_boss", "bass": "octave8", "arp": "ostinato",
				"lead": "lead_sq", "lead2": "brass", "stabs": "x.x...x...x.x...", "choir": 1.1, "melody": [
				"D6 - - - A5 - - - F5 - - - D5 - F5 -",
				"Bb5 - - - - - - - D6 - - - F6 - - -",
				"G6 - - - F6 - D6 - Bb5 - - - D6 - G6 -",
				"A6 - - - - - - - E6 - - - C#6 - - -",
				"D6 - - - - - - - F6 - - - Bb6 - - -",
				"A6 - - - - - - - - - - - . . . ."]},
			# Logo: ein letzter Schlag, dann D-Dur über bVI und bVII zurück nach D
			{"name": "final", "gain": 1.1, "chords": ["D"], "drums": "hit", "choir": 1.1, "fill": false, "melody": [
				"D6 - - - - - - - - - - - - - - -"]},
			{"name": "outro", "gain": 0.8, "chords": ["Bb", "C", "D"], "choir": 1.0, "fill": false, "melody": [
				"D6 - - - F6 - - - - - - - - - - -",
				"E6 - - - G6 - - - - - - - - - - -",
				"F#6 - - - - - - - - - - - - - - -"]},
		],
	},
}

## Schlagzeug-Spuren (16 Schritte): k Kick, s Snare, h Hi-Hat, t Pauke
const DRUMS := {
	"battle": {"k": "x.....x.x.....x.", "s": "....x.......x...", "h": "x.xxx.xxx.xxx.xx", "vol": 1.0},
	"map": {"k": "x.......x.......", "s": "....x.......x...", "h": "..x...x...x...x.", "vol": 0.55},
	"title": {"k": "x.......x.x.....", "s": "....x.......x...", "h": "x.x.x.x.x.x.x.x.", "vol": 0.7},
	"boss": {"k": "x..x..x.x..x..x.", "s": "....x.......x...", "h": "xxxxxxxxxxxxxxxx", "t": "x.......x.......", "vol": 1.0},
	"guard": {"k": "x.x...x.x.x...x.", "s": "....x..x....x...", "h": "x.xxx.xxx.xxx.xx", "t": "x.......x.....x.", "vol": 1.0},
	# Kino-Intro: Pauken, die sich aufbauen · ein einzelner Schlag (Absturz)
	"timp_build": {"k": "x.......x.......", "s": "................", "h": "................", "t": "x...x...x.x.x.xx", "vol": 0.9},
	"hit": {"k": "x...............", "s": "................", "h": "................", "t": "x...............", "vol": 1.0},
	"none": {"k": "................", "s": "................", "h": "................", "vol": 0.0},
	# Vulkan: schwere Pauken · Sumpf: hüpfender Shuffle
	"vulkan_map": {"k": "x.......x.......", "s": "............x...", "h": "..x...x...x...x.", "t": "x.....x...x.....", "vol": 0.6},
	"vulkan": {"k": "x.x...x.x.x...x.", "s": "....x.......x...", "h": "x.xxx.xxx.xxx.xx", "t": "......x.......x.", "vol": 1.0},
	"sumpf_map": {"k": "x.....x...x.....", "s": "....x.......x..x", "h": "x..x..x.x..x..x.", "vol": 0.5},
	"sumpf": {"k": "x..x....x..x....", "s": "....x.......x...", "h": "x.xxx.xxx.xxx.xx", "vol": 0.95},
	"see_map": {"k": "x.......x.......", "s": "............x...", "h": "..x...x...x...x.", "vol": 0.45},
	"see": {"k": "x...x.x.x...x.x.", "s": "....x.......x...", "h": "x.xxx.xxx.xxx.xx", "vol": 0.95},
	"steppe_map": {"k": "x.....x.x.......", "s": "....x.......x...", "h": "x.x.x.x.x.x.x.x.", "t": "..............x.", "vol": 0.55},
	"steppe": {"k": "x.x...x.x.x...x.", "s": "....x.......x..x", "h": "xxxxxxxxxxxxxxxx", "t": "......x.......x.", "vol": 1.0},
	# Epische Fassungen (08.10.2026): Taiko-Pauken (tf = Tonhöhe), Titel im halben Takt, Station ganz leise
	"epic_title": {"k": "x.......x.......", "s": "........x.......", "h": "..x...x...x...x.", "t": "x.....x.x.....x.", "tf": 58.0, "vol": 0.75},
	"home": {"k": "x.......x.......", "s": "................", "h": "....x.......x...", "vol": 0.3},
	"taiko": {"k": "x.......x.......", "s": "................", "h": "................", "t": "x..x..x.x..x..x.", "tf": 58.0, "vol": 0.9},
	"epic_battle": {"k": "x..x..x.x..x..x.", "s": "....x.......x...", "h": "x.x.x.x.x.x.x.x.", "t": "x.....x...x.x...", "tf": 62.0, "vol": 1.0},
	"epic_boss": {"k": "x.xx..x.x.xx..x.", "s": "....x.......x...", "h": "xxxxxxxxxxxxxxxx", "t": "x..x..x...x..x..", "tf": 52.0, "vol": 1.0},
	# Trailer: Herzschlag des Eis (tiefe Pauke, doppelter Schlag)
	"heart": {"k": "x..x....x..x....", "s": "................", "h": "................", "t": "x..x....x..x....", "tf": 46.0, "vol": 0.8},
}

var L := PackedFloat32Array()
var R := PackedFloat32Array()
var SEND := PackedFloat32Array()
var rng := RandomNumberGenerator.new()


# ---------- Hilfen ----------

static func midi(note: String) -> int:
	var octave := int(note.substr(note.length() - 1))
	return 12 * (octave + 1) + NOTE_INDEX[note.substr(0, note.length() - 1)]


static func freq(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)


## Tonhöhenklassen eines Akkords, Grundton zuerst
static func chord_pcs(sym: String) -> Array:
	var minor := sym.ends_with("m")
	var root_name := sym.substr(0, sym.length() - (1 if minor else 0))
	var r: int = NOTE_INDEX[root_name]
	return [r, (r + (3 if minor else 4)) % 12, (r + 7) % 12]


## Akkordtöne im Bereich [lo, lo+12)
static func voicing(sym: String, lo: int) -> Array:
	var out: Array = []
	for pc in chord_pcs(sym):
		var m: int = lo + ((pc - lo) % 12 + 12) % 12
		out.append(m)
	out.sort()
	return out


## Länge des Intros in Frames (Schleifenbeginn)
static func intro_frames(key: String) -> int:
	var tr: Dictionary = TRACKS[key]
	var sec: Dictionary = tr.sections[0]
	if sec.name != "intro":
		return 0
	return int(sec.chords.size() * 4 * 60.0 / tr.bpm * RATE)


# ---------- Rendern ----------

static func render(key: String) -> AudioStreamWAV:
	var s := MusicSynth.new()
	return s._render(key)


func _render(key: String) -> AudioStreamWAV:
	rng.seed = 42
	var tr: Dictionary = TRACKS[key]
	var step: float = 60.0 / tr.bpm / 4.0
	var bar := step * 16.0
	var total_bars := 0
	for sec in tr.sections:
		total_bars += sec.chords.size()
	var n := int(total_bars * bar * RATE) + RATE  # 1 s Ausklang für das Echo, wird unten zurückgefaltet
	L.resize(n)
	R.resize(n)
	SEND.resize(n)
	var t := 0.0
	var gains: Array = []   # [Start, Ende, Lautstärke] je Abschnitt (Trailer: Dynamik von leise bis Höhepunkt)
	for sec in tr.sections:
		var bars: int = sec.chords.size()
		gains.append([t, t + bars * bar, float(sec.get("gain", 1.0))])
		var is_intro: bool = sec.name == "intro"
		# Abschnitte können Lead, Bass, Begleitung, Stabs und Schlagzeug überschreiben (Kino-Intro)
		var lead: String = sec.get("lead", tr.lead)
		var bass: String = sec.get("bass", tr.bass)
		var arp: String = sec.get("arp", tr.arp)
		var stabs: String = sec.get("stabs", tr.stabs)
		var drums: String = sec.get("drums", tr.drums)
		var fill_end: bool = sec.get("fill", true)
		# Melodie (über Taktgrenzen gebunden)
		var notes := _parse_melody(" ".join(sec.melody), t, step)
		var lead2: String = sec.get("lead2", tr.get("lead2", ""))
		var dbl: String = sec.get("double", tr.get("double", ""))
		for nt in notes:
			_lead(lead, nt.t, nt.d, nt.m, 0.9)
			if lead == "brass" and tr.get("glock", true):
				_glock(nt.t, nt.d, nt.m + 12, 0.18, 0.3)
			# zweite Lead-Stimme (leiser) und Dopplung eine Oktave tiefer: macht die Melodie breiter (epische Stücke)
			if lead2 != "":
				_lead(lead2, nt.t, nt.d, nt.m, 0.5)
			if dbl == "strings":
				_strings(nt.t, nt.d, nt.m - 12, 0.6, -0.15)
		# Chor: eine Fläche je Folge gleicher Akkorde (sonst schwillt er jeden Takt neu an)
		var choir: float = sec.get("choir", tr.get("choir", 0.0))
		if choir > 0.0:
			var b0 := 0
			while b0 < bars:
				var b1 := b0
				while b1 + 1 < bars and sec.chords[b1 + 1] == sec.chords[b0]:
					b1 += 1
				if sec.chords[b0] != "-":
					_choir_chord(sec.chords[b0], t + b0 * bar, (b1 - b0 + 1) * bar, choir)
				b0 = b1 + 1
		# Gegenstimme im B-Teil
		if sec.name == "B":
			for nt in notes:
				var ch: String = sec.chords[clampi(int((nt.t - t) / bar), 0, bars - 1)]
				var cm := _counter_note(nt.m, ch)
				if cm > 0:
					if tr.counter == "brass":
						_brass(nt.t, nt.d, cm, 0.4, -0.35)
					else:
						_strings(nt.t, nt.d, cm, 0.35, -0.4)
		for b in bars:
			var tb := t + b * bar
			var ch: String = sec.chords[b]
			if ch != "-":   # "-" = stiller Takt (nur Schlagzeug)
				_pad(ch, tb, bar, 0.45 if bass == "octave8" else 0.4)
				_bass_bar(bass, ch, tb, step)
				_arp_bar(arp, ch, tb, step)
				if stabs != "" and (is_intro or b % 2 == 0):
					_stabs(stabs, ch, tb, step)
			_drum_bar(drums, tb, step, fill_end and b == bars - 1, b == 0)
		t += bars * bar
	if gains.any(func(g): return g[2] != 1.0):
		_section_gain(gains)
	_echo(tr.bpm)
	# One-Shot-Stücke (Kino-Intro) laufen einmal durch und behalten ihren Ausklang
	return _to_wav(key, L.size() if tr.get("oneshot", false) else int(total_bars * bar * RATE))


## Lautstärke je Abschnitt anwenden, an den Grenzen in 60 ms überblendet (auch der Echo-Anteil, damit Ausklänge mitgehen)
func _section_gain(gains: Array) -> void:
	var xf := int(0.06 * RATE)
	for gi in gains.size():
		var g: Array = gains[gi]
		var g_prev: float = gains[gi - 1][2] if gi > 0 else g[2]
		var i0 := int(g[0] * RATE)
		var i1 := L.size() if gi == gains.size() - 1 else int(g[1] * RATE)
		for i in range(i0, mini(i1, L.size())):
			var k: float = g[2] if i - i0 >= xf else lerpf(g_prev, g[2], float(i - i0) / xf)
			L[i] *= k
			R[i] *= k
			SEND[i] *= k


func _parse_melody(s: String, t0: float, step: float) -> Array:
	var tokens := s.split(" ", false)
	var out: Array = []
	var i := 0
	while i < tokens.size():
		var tok := tokens[i]
		if tok == "." or tok == "-":
			i += 1
			continue
		var len := 1
		while i + len < tokens.size() and tokens[i + len] == "-":
			len += 1
		out.append({"t": t0 + i * step, "d": len * step, "m": midi(tok)})
		i += len
	return out


## Terz oder Sexte unter der Melodie, passend zum Akkord
func _counter_note(m: int, chord: String) -> int:
	var pcs := chord_pcs(chord)
	for dist in [3, 4, 8, 9, 5]:
		if pcs.has((m - dist) % 12):
			return m - dist
	return 0


# ---------- Instrumente ----------

func _pan_gains(pan: float) -> Vector2:
	var a := (pan + 1.0) * PI / 4.0
	return Vector2(cos(a), sin(a))


## Hüllkurve: Anschlag, Abfall auf Haltepegel, Ausklang am Notenende
static func _env(i: int, n: int, a: float, d: float, s: float, rel: float) -> float:
	var tt := float(i) / RATE
	var e := 1.0
	if tt < a:
		e = tt / a
	elif tt < a + d:
		e = 1.0 - (1.0 - s) * (tt - a) / d
	else:
		e = s
	var left := float(n - i) / RATE
	if left < rel:
		e *= left / rel
	return e


func _write(idx: int, v: float, g: Vector2, send: float) -> void:
	L[idx] += v * g.x
	R[idx] += v * g.y
	SEND[idx] += v * send


func _lead(kind: String, t: float, dur: float, m: int, vel: float) -> void:
	match kind:
		"lead_sq":
			_square_lead(t, dur, m, vel * 0.16)
		"lead_soft":
			_flute(t, dur, m, vel * 0.2)
		"brass":
			_brass(t, dur, m, vel * 0.85, 0.0)


## Rechteck-Lead (25 %) mit gefiltertem Sägezahn für Körper, Vibrato nach kurzer Zeit
func _square_lead(t: float, dur: float, m: int, vol: float) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE * 0.97)
	var f := freq(m)
	var ph := 0.0
	var lp := 0.0
	var g := _pan_gains(0.05)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		var vib := 1.0 + (0.006 * sin(tt * TAU * 5.5) * minf(1.0, (tt - 0.18) * 4.0) if tt > 0.18 else 0.0)
		ph = fmod(ph + f * vib / RATE, 1.0)
		var sq := 1.0 if ph < 0.25 else -1.0
		lp += 0.25 * ((2.0 * ph - 1.0) - lp)
		var v := (sq * 0.7 + lp * 0.6) * vol * _env(i, n, 0.006, 0.12, 0.75, 0.04)
		_write(idx, v, g, 0.35)


## Weiche Flöte: Dreieck + Sinus, etwas Atemrauschen
func _flute(t: float, dur: float, m: int, vol: float) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE * 0.95)
	var f := freq(m)
	var ph := 0.0
	var nz := 0.0
	var g := _pan_gains(0.0)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		var vib := 1.0 + (0.007 * sin(tt * TAU * 5.0) if tt > 0.2 else 0.0)
		ph = fmod(ph + f * vib / RATE, 1.0)
		var tri := 4.0 * absf(ph - 0.5) - 1.0
		nz += 0.1 * (rng.randf_range(-1.0, 1.0) - nz)
		var v := (tri * 0.75 + sin(ph * TAU) * 0.5 + nz * 0.15) * vol * _env(i, n, 0.03, 0.1, 0.85, 0.06)
		_write(idx, v, g, 0.35)


## Blech: Sägezahn durch Tiefpass, der beim Anschlag aufgeht („Bwaah“)
func _brass(t: float, dur: float, m: int, vel: float, pan: float) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE * 0.95)
	var f := freq(m)
	var ph := 0.0
	var ph2 := 0.0
	var lp := 0.0
	var g := _pan_gains(pan)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		var vib := 1.0 + (0.004 * sin(tt * TAU * 5.0) if tt > 0.25 else 0.0)
		ph = fmod(ph + f * vib / RATE, 1.0)
		ph2 = fmod(ph2 + f * 1.004 * vib / RATE, 1.0)
		var saw := (2.0 * ph - 1.0) + (2.0 * ph2 - 1.0) * 0.6
		var cutoff := 900.0 + 2600.0 * exp(-tt * 9.0) + 500.0 * minf(1.0, tt * 3.0)
		lp += (1.0 - exp(-TAU * cutoff / RATE)) * (saw - lp)
		var v := lp * 0.11 * vel * _env(i, n, 0.02, 0.2, 0.7, 0.06)
		_write(idx, v, g, 0.22)


## Streicher: drei leicht verstimmte Sägezähne, weicher Anschlag
func _strings(t: float, dur: float, m: int, vel: float, pan: float) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE)
	var f := freq(m)
	var ph := [rng.randf(), rng.randf(), rng.randf()]
	var det := [0.9954, 1.0, 1.0046]
	var lp := 0.0
	var a := 1.0 - exp(-TAU * 2400.0 / RATE)
	var g := _pan_gains(pan)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var s := 0.0
		for k in 3:
			ph[k] = fmod(ph[k] + f * det[k] / RATE, 1.0)
			s += 2.0 * ph[k] - 1.0
		lp += a * (s - lp)
		var v := lp * 0.035 * vel * _env(i, n, 0.09, 0.2, 0.85, 0.12)
		_write(idx, v, g, 0.18)


## Akkordfläche aus Streichern, links und rechts leicht unterschiedlich
func _pad(chord: String, t: float, dur: float, vel: float) -> void:
	var notes := voicing(chord, 55)
	for i in notes.size():
		_strings(t, dur, notes[i], vel, -0.55 + 0.55 * i)


## Chor („Aah“): vier leicht verstimmte Sägezähne durch zwei Formantfilter (ca. 730 und 1090 Hz), langsamer Anschlag
func _choir(t: float, dur: float, m: int, vel: float, pan: float) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE)
	var f := freq(m)
	var det := [0.993, 0.998, 1.002, 1.007]
	var ph := [rng.randf(), rng.randf(), rng.randf(), rng.randf()]
	var f1 := 2.0 * sin(PI * 730.0 / RATE)
	var f2 := 2.0 * sin(PI * 1090.0 / RATE)
	var q := 0.3
	var l1 := 0.0
	var b1 := 0.0
	var l2 := 0.0
	var b2 := 0.0
	var g := _pan_gains(pan)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		var vib := 1.0 + 0.003 * sin(tt * TAU * 4.7 + m)
		var sm := 0.0
		for k in 4:
			ph[k] = fmod(ph[k] + f * det[k] * vib / RATE, 1.0)
			sm += 2.0 * ph[k] - 1.0
		sm *= 0.25
		l1 += f1 * b1
		var h1 := sm - l1 - q * b1
		b1 += f1 * h1
		l2 += f2 * b2
		var h2 := sm - l2 - q * b2
		b2 += f2 * h2
		var v := (b1 * 0.9 + b2 * 0.6 + l1 * 0.12) * 0.075 * vel * _env(i, n, 0.35, 0.3, 0.9, 0.3)
		_write(idx, v, g, 0.3)


## Chor-Akkord: drei Stimmen in mittlerer Lage, über das Stereofeld verteilt
func _choir_chord(chord: String, t: float, dur: float, vel: float) -> void:
	var notes := voicing(chord, 57)
	for i in notes.size():
		_choir(t, dur, notes[i], vel, -0.45 + 0.45 * i)


## Spiccato-Streicher: kurz gestrichen, zwei verstimmte Sägezähne durch schließenden Tiefpass
func _spiccato(t: float, dur: float, m: int, vol: float, pan: float) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE * 0.85)
	var f := freq(m)
	var ph := rng.randf()
	var ph2 := rng.randf()
	var lp := 0.0
	var g := _pan_gains(pan)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		ph = fmod(ph + f / RATE, 1.0)
		ph2 = fmod(ph2 + f * 1.006 / RATE, 1.0)
		var saw := (2.0 * ph - 1.0) + (2.0 * ph2 - 1.0)
		var cutoff := 700.0 + 2200.0 * exp(-tt * 25.0)
		lp += (1.0 - exp(-TAU * cutoff / RATE)) * (saw - lp)
		var v := lp * 0.05 * vol * _env(i, n, 0.004, 0.06, 0.45, 0.02)
		_write(idx, v, g, 0.12)


## Glockenspiel: Sinus mit unharmonischen Obertönen, klingt aus
func _glock(t: float, dur: float, m: int, vol: float, pan: float) -> void:
	var start := int(t * RATE)
	var n := int(minf(maxf(dur, 0.35), 0.9) * RATE)
	var f := freq(m)
	var g := _pan_gains(pan)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		var s := sin(tt * f * TAU) + 0.4 * sin(tt * f * 3.01 * TAU) * exp(-tt * 8.0) + 0.15 * sin(tt * f * 5.43 * TAU) * exp(-tt * 14.0)
		var v := s * vol * 0.22 * exp(-tt * 4.5) * minf(1.0, tt / 0.002)
		_write(idx, v, g, 0.4)


## Gezupft (Marimba/Pizzicato-artig): Rechteck durch schnell schließenden Tiefpass
func _pluck(t: float, dur: float, m: int, vol: float, pan: float) -> void:
	var start := int(t * RATE)
	var n := int(minf(dur, 0.3) * RATE)
	var f := freq(m)
	var ph := 0.0
	var lp := 0.0
	var g := _pan_gains(pan)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		ph = fmod(ph + f / RATE, 1.0)
		var sq := 1.0 if ph < 0.5 else -1.0
		var cutoff := 400.0 + 4000.0 * exp(-tt * 30.0)
		lp += (1.0 - exp(-TAU * cutoff / RATE)) * (sq - lp)
		var v := lp * vol * 0.1 * exp(-tt * 9.0) * minf(1.0, tt / 0.002)
		_write(idx, v, g, 0.25)


## Bass: gezupft (Kampf) oder weich (Karte/Titel)
func _bass(t: float, dur: float, m: int, vol: float, hard: bool) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE * 0.9)
	var f := freq(m)
	var ph := 0.0
	var lp := 0.0
	var g := _pan_gains(0.0)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var tt := float(i) / RATE
		ph = fmod(ph + f / RATE, 1.0)
		var v := 0.0
		if hard:
			var raw := (1.0 if ph < 0.5 else -1.0) * 0.5 + (2.0 * ph - 1.0) * 0.6
			var cutoff := 500.0 + 1800.0 * exp(-tt * 18.0)
			lp += (1.0 - exp(-TAU * cutoff / RATE)) * (raw - lp)
			v = lp * 0.3
		else:
			v = (4.0 * absf(ph - 0.5) - 1.0) * 0.28 + sin(ph * TAU) * 0.18
		v *= vol * _env(i, n, 0.004, 0.15, 0.7, 0.03)
		_write(idx, v, g, 0.0)


# ---------- Begleitmuster ----------

func _bass_bar(style: String, chord: String, t: float, step: float) -> void:
	var root: int = voicing(chord, 36)[0]
	for nt in voicing(chord, 36):
		if nt % 12 == chord_pcs(chord)[0]:
			root = nt
	var fifth := root + 7
	match style:
		"octave8":
			# treibende Achtel-Oktaven wie in den Kampfthemen
			for s in range(0, 16, 2):
				_bass(t + s * step, step * 2, root + (12 if s % 4 == 2 else 0), 1.0, true)
		"bounce":
			var seq := [[0, root], [4, fifth], [6, root + 12], [8, root], [12, fifth], [14, root + 12]]
			for e in seq:
				_bass(t + e[0] * step, step * 2, e[1], 0.9, false)
		"half":
			_bass(t, step * 8, root, 1.0, false)
			_bass(t + 8 * step, step * 6, root + 12 if chord.ends_with("m") else fifth, 0.9, false)
			_bass(t + 14 * step, step * 2, fifth, 0.7, false)


func _arp_bar(style: String, chord: String, t: float, step: float) -> void:
	var v := voicing(chord, 72)
	match style:
		"arp16":
			var order := [0, 1, 2, 1]
			for s in 16:
				_pluck(t + s * step, step, v[order[s % 4]] + (12 if s >= 8 and s % 4 == 2 else 0), 0.55, 0.35)
		"arp8":
			var order := [0, 2, 1, 2]
			for s in range(0, 16, 2):
				_glock(t + s * step, step * 2, v[order[(s / 2) % 4]], 0.42, 0.4)
		"ostinato":
			# treibende Sechzehntel der Streicher in tiefer Lage: Grundton, Quinte, Oktave (epische Stücke)
			var r: int = voicing(chord, 45)[0]
			for nt in voicing(chord, 45):
				if nt % 12 == chord_pcs(chord)[0]:
					r = nt
			var seq := [0, 0, 7, 0, 12, 0, 7, 0, 0, 0, 7, 0, 12, 7, 12, 7]
			for st in 16:
				_spiccato(t + st * step, step, r + seq[st], 0.5 if st % 4 == 0 else 0.38, 0.2 if st % 2 == 0 else -0.2)
		"offbeat":
			# gezupfte Akkorde auf den Offbeats (Sumpf: blubbert)
			for s in [2, 6, 10, 14]:
				for i in v.size():
					_pluck(t + s * step, step * 1.5, v[i], 0.3, -0.3 + 0.3 * i)


func _stabs(pattern: String, chord: String, t: float, step: float) -> void:
	var v := voicing(chord, 60)
	for s in 16:
		if pattern[s] == "x":
			for i in v.size():
				_brass(t + s * step, step * 1.6, v[i], 0.55, -0.3 + 0.3 * i)


func _drum_bar(style: String, t: float, step: float, fill: bool, first: bool) -> void:
	var D: Dictionary = DRUMS[style]
	var vol: float = D.vol
	if first:
		_crash(t, 0.35 * vol)
	for s in 16:
		var ts := t + s * step
		if fill and s >= 8:
			# Wirbel zum Abschnittsende
			_snare(ts, 0.22 * vol * (0.6 + 0.05 * (s - 8)))
			if s % 2 == 0:
				_tom(ts, 0.4 * vol, 200.0 - (s - 8) * 12.0)
			continue
		if D.k[s] == "x":
			_kick(ts, 0.55 * vol)
		if D.s[s] == "x":
			_snare(ts, 0.3 * vol)
		if D.h[s] == "x":
			_hat(ts, (0.07 if s % 2 == 0 else 0.045) * vol)
		if D.has("t") and D.t[s] == "x":
			_tom(ts, 0.45 * vol, D.get("tf", 70.0))


func _kick(t: float, vol: float) -> void:
	var start := int(t * RATE)
	var n := int(0.16 * RATE)
	var ph := 0.0
	var g := _pan_gains(0.0)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var k := float(i) / n
		ph += (160.0 * pow(0.2, k * 2.5) + 42.0) / RATE
		var v := sin(ph * TAU) * vol * (1.0 - k) * (1.0 - k) + (rng.randf_range(-1, 1) * 0.3 * vol if i < 60 else 0.0)
		_write(idx, v, g, 0.0)


func _snare(t: float, vol: float) -> void:
	var start := int(t * RATE)
	var n := int(0.16 * RATE)
	var lp := 0.0
	var g := _pan_gains(-0.1)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var k := float(i) / n
		var nz := rng.randf_range(-1.0, 1.0)
		lp += 0.55 * (nz - lp)
		var body := sin(float(i) / RATE * 190.0 * TAU) * exp(-k * 12.0) * 0.6
		var v := (nz - lp * 0.6 + body) * vol * pow(1.0 - k, 2.5)
		_write(idx, v, g, 0.12)


func _hat(t: float, vol: float) -> void:
	var start := int(t * RATE)
	var n := int(0.04 * RATE)
	var last := 0.0
	var g := _pan_gains(0.3)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var nz := rng.randf_range(-1.0, 1.0)
		var hp := nz - last
		last = nz
		var k := float(i) / n
		_write(idx, hp * vol * (1.0 - k), g, 0.05)


func _crash(t: float, vol: float) -> void:
	var start := int(t * RATE)
	var n := int(1.1 * RATE)
	var last := 0.0
	var g := _pan_gains(-0.25)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var nz := rng.randf_range(-1.0, 1.0)
		var hp := nz - last
		last = nz
		var k := float(i) / n
		_write(idx, hp * vol * pow(1.0 - k, 3.0) * 0.5, g, 0.2)


func _tom(t: float, vol: float, f0: float) -> void:
	var start := int(t * RATE)
	var n := int(0.25 * RATE)
	var ph := 0.0
	var g := _pan_gains(0.15)
	for i in n:
		var idx := start + i
		if idx >= L.size():
			return
		var k := float(i) / n
		ph += f0 * (1.0 - 0.35 * k) / RATE
		_write(idx, sin(ph * TAU) * vol * pow(1.0 - k, 2.0), g, 0.1)


# ---------- Echo & Ausgabe ----------

## Ping-Pong-Echo im Takt (punktierte Achtel), Anteil über die Send-Spur
func _echo(bpm: float) -> void:
	var d := int(60.0 / bpm * 0.75 * RATE)
	var el := PackedFloat32Array()
	var er := PackedFloat32Array()
	el.resize(L.size())
	er.resize(L.size())
	var fb := 0.38
	var lpl := 0.0
	var lpr := 0.0
	for i in L.size():
		var inl := SEND[i - d] if i >= d else 0.0
		var fr := er[i - d] if i >= d else 0.0
		var fl := el[i - d] if i >= d else 0.0
		lpl += 0.35 * ((inl + fr * fb) - lpl)
		lpr += 0.35 * ((fl * fb) - lpr)
		el[i] = lpl
		er[i] = lpr
	for i in L.size():
		L[i] += el[i] * 0.55
		R[i] += er[i] * 0.55


func _to_wav(key: String, loop_len: int) -> AudioStreamWAV:
	# Ausklang über das Schleifenende hinaus an den Schleifenanfang zurückfalten (nahtlose Schleife)
	var lb := intro_frames(key)
	for i in range(loop_len, L.size() if not TRACKS[key].get("oneshot", false) else loop_len):
		var j := lb + (i - loop_len)
		if j < loop_len:
			L[j] += L[i]
			R[j] += R[i]
	# Lautheit angleichen (RMS-Ziel je Stück), Spitzen fängt die weiche Sättigung ab
	var sum := 0.0
	for i in loop_len:
		sum += L[i] * L[i] + R[i] * R[i]
	var rms := sqrt(sum / (2.0 * loop_len)) + 0.000001
	var gain: float = TRACKS[key].loud / rms
	var data := PackedByteArray()
	data.resize(loop_len * 4)
	for i in loop_len:
		data.encode_s16(i * 4, int(clampf(tanh(L[i] * gain), -1.0, 1.0) * 32000.0))
		data.encode_s16(i * 4 + 2, int(clampf(tanh(R[i] * gain), -1.0, 1.0) * 32000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = true
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED if TRACKS[key].get("oneshot", false) else AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = lb
	wav.loop_end = loop_len
	return wav
