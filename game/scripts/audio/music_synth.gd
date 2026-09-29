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
}

## Schlagzeug-Spuren (16 Schritte): k Kick, s Snare, h Hi-Hat, t Pauke
const DRUMS := {
	"battle": {"k": "x.....x.x.....x.", "s": "....x.......x...", "h": "x.xxx.xxx.xxx.xx", "vol": 1.0},
	"map": {"k": "x.......x.......", "s": "....x.......x...", "h": "..x...x...x...x.", "vol": 0.55},
	"title": {"k": "x.......x.x.....", "s": "....x.......x...", "h": "x.x.x.x.x.x.x.x.", "vol": 0.7},
	"boss": {"k": "x..x..x.x..x..x.", "s": "....x.......x...", "h": "xxxxxxxxxxxxxxxx", "t": "x.......x.......", "vol": 1.0},
	"none": {"k": "................", "s": "................", "h": "................", "vol": 0.0},
	# Vulkan: schwere Pauken · Sumpf: hüpfender Shuffle
	"vulkan_map": {"k": "x.......x.......", "s": "............x...", "h": "..x...x...x...x.", "t": "x.....x...x.....", "vol": 0.6},
	"vulkan": {"k": "x.x...x.x.x...x.", "s": "....x.......x...", "h": "x.xxx.xxx.xxx.xx", "t": "......x.......x.", "vol": 1.0},
	"sumpf_map": {"k": "x.....x...x.....", "s": "....x.......x..x", "h": "x..x..x.x..x..x.", "vol": 0.5},
	"sumpf": {"k": "x..x....x..x....", "s": "....x.......x...", "h": "x.xxx.xxx.xxx.xx", "vol": 0.95},
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
	for sec in tr.sections:
		var bars: int = sec.chords.size()
		var is_intro: bool = sec.name == "intro"
		# Melodie (über Taktgrenzen gebunden)
		var notes := _parse_melody(" ".join(sec.melody), t, step)
		for nt in notes:
			_lead(tr.lead, nt.t, nt.d, nt.m, 0.9)
			if tr.lead == "brass":
				_glock(nt.t, nt.d, nt.m + 12, 0.18, 0.3)
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
			_pad(ch, tb, bar, 0.45 if tr.bass == "octave8" else 0.4)
			_bass_bar(tr.bass, ch, tb, step)
			_arp_bar(tr.arp, ch, tb, step)
			if tr.stabs != "" and (is_intro or b % 2 == 0):
				_stabs(tr.stabs, ch, tb, step)
			_drum_bar(tr.drums, tb, step, b == bars - 1, b == 0)
		t += bars * bar
	_echo(tr.bpm)
	return _to_wav(key, int(total_bars * bar * RATE))


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
			_tom(ts, 0.45 * vol, 70.0)


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
	for i in range(loop_len, L.size()):
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
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = lb
	wav.loop_end = loop_len
	return wav
