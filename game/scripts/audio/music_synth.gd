class_name MusicSynth
extends RefCounted
## Kleiner Chiptune-Sequenzer: rendert die Platzhalter-Musik als WAV (tools/render_music.gd).
## Melodie von Hand notiert (16 Schritte = 1 Takt, "-" = halten, "." = Pause), Bass, Arpeggio und
## Schlagzeug werden aus der Akkordfolge erzeugt. Später durch echte Musik ersetzbar.

const RATE := 22050

const NOTE_INDEX := {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6,
	"G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}

## Stücke: Tempo, Akkorde je Takt (Grundton + "m" für Moll), Melodie je Takt, Stil für Bass/Arpeggio/Schlagzeug
const TRACKS := {
	"title": {
		"bpm": 116, "style": "title",
		"chords": ["F", "G", "Em", "Am", "F", "G", "C", "C"],
		"melody": [
			"C5 - F5 - A5 - - - G5 - F5 - E5 - F5 -",
			"D5 - G5 - B5 - - - A5 - G5 - F5 - G5 -",
			"E5 - - - G5 - - - B5 - - - A5 - G5 -",
			"A5 - - - - - - - E5 - - - . . . .",
			"F5 - E5 - F5 - A5 - C6 - - - A5 - - -",
			"B5 - A5 - G5 - F5 - G5 - - - D5 - - -",
			"E5 - - - G5 - - - C6 - - - - - - -",
			". . . . G5 - E5 - C5 - - - . . . .",
		],
	},
	"map": {
		"bpm": 100, "style": "map",
		"chords": ["C", "Am", "F", "G", "C", "Am", "Dm", "G"],
		"melody": [
			"E5 - - - G5 - - - E5 - D5 - C5 - - -",
			"A4 - - - C5 - - - E5 - - - . . . .",
			"F5 - - - E5 - - - D5 - C5 - A4 - - -",
			"G4 - - - B4 - - - D5 - - - . . . .",
			"C5 - E5 - G5 - - - A5 - G5 - E5 - - -",
			"C5 - - - E5 - D5 - C5 - - - A4 - - -",
			"D5 - - - F5 - - - A5 - G5 - F5 - - -",
			"G5 - - - F5 - - - D5 - - - B4 - - -",
		],
	},
	"battle": {
		"bpm": 140, "style": "battle",
		"chords": ["Am", "F", "C", "G", "Am", "F", "G", "E"],
		"melody": [
			"A4 - . A4 C5 - E5 - D5 - C5 - B4 - A4 -",
			"F4 - A4 - C5 - A4 - C5 - D5 - C5 - A4 -",
			"G4 - C5 - E5 - G5 - E5 - D5 - C5 - D5 -",
			"B4 - - - D5 - - - G4 - B4 - D5 - - -",
			"E5 - - E5 D5 - C5 - D5 - E5 - A5 - - -",
			"A5 - G5 - F5 - E5 - F5 - E5 - D5 - C5 -",
			"B4 - D5 - G5 - F5 - E5 - D5 - B4 - D5 -",
			"E5 - - - G#5 - - - B5 - - - . . . .",
		],
	},
	"boss": {
		"bpm": 150, "style": "boss",
		"chords": ["Dm", "Bb", "C", "A", "Dm", "Bb", "Gm", "A"],
		"melody": [
			"D5 - D5 - F5 - D5 - A5 - - - G5 - F5 -",
			"F5 - D5 - Bb4 - D5 - F5 - - - G5 - F5 -",
			"E5 - - - G5 - - - C6 - - - Bb5 - A5 -",
			"A5 - - - C#6 - - - E6 - - - . . . .",
			"D6 - - - A5 - - - F5 - - - D5 - - -",
			"D5 - F5 - Bb5 - A5 - G5 - F5 - D5 - F5 -",
			"G5 - - - Bb5 - - - D6 - C6 - Bb5 - A5 -",
			"A5 - - - E5 - - - C#5 - - - A4 - - -",
		],
	},
}

## Schlagzeug je Stil: k = Kick, s = Snare, h = Hi-Hat (16 Schritte)
const DRUMS := {
	"title": "k.h.s.hkk.h.s.h.",
	"map": "k...h...k...h...",
	"battle": "k.h.s.h.k.hks.h.",
	"boss": "k.hks.h.k.hks.hh",
}


static func midi(note: String) -> int:
	var name := note.substr(0, note.length() - 1)
	var octave := int(note.substr(note.length() - 1))
	return 12 * (octave + 1) + NOTE_INDEX[name]


static func freq(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)


## Akkordtöne (MIDI) in der Oktave um `base`
static func chord_notes(chord: String, base: int) -> Array:
	var minor := chord.ends_with("m")
	var root_name := chord.substr(0, chord.length() - (1 if minor else 0))
	var root: int = base + NOTE_INDEX[root_name]
	return [root, root + (3 if minor else 4), root + 7]


## Rendert ein Stück (2 Durchgänge à 8 Takte; im zweiten Durchgang spielt das Arpeggio eine Oktave höher).
static func render(key: String) -> AudioStreamWAV:
	var tr: Dictionary = TRACKS[key]
	var step_len: float = 60.0 / tr.bpm / 4.0
	var bars: int = tr.chords.size()
	var passes := 2
	var total_steps := bars * 16 * passes
	var n := int(total_steps * step_len * RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var style: String = tr.style
	for p in passes:
		for b in bars:
			var chord: String = tr.chords[b]
			var t0 := (p * bars + b) * 16 * step_len
			_melody_bar(buf, tr.melody[b], t0, step_len, 0.16 if style != "map" else 0.13, 0.25 if p == 0 else 0.125)
			_bass_bar(buf, chord, style, t0, step_len)
			_arp_bar(buf, chord, style, t0, step_len, 5 if p == 1 else 4)
			_drum_bar(buf, DRUMS[style], t0, step_len, style)
	# Mischen: sanft begrenzen und in 16 Bit schreiben
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var v := int(clampf(tanh(buf[i] * 1.2), -1.0, 1.0) * 30000.0)
		data.encode_s16(i * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = n
	return wav


static func _melody_bar(buf: PackedFloat32Array, bar: String, t0: float, step: float, vol: float, duty: float) -> void:
	var tokens := bar.split(" ", false)
	var i := 0
	while i < tokens.size():
		var tok := tokens[i]
		if tok == "." or tok == "-":
			i += 1
			continue
		var len := 1
		while i + len < tokens.size() and tokens[i + len] == "-":
			len += 1
		_tone(buf, t0 + i * step, len * step * 0.95, freq(midi(tok)), "pulse", vol, duty, true)
		i += len


static func _bass_bar(buf: PackedFloat32Array, chord: String, style: String, t0: float, step: float) -> void:
	var c := chord_notes(chord, 36)
	var root: int = c[0]
	var fifth: int = c[2]
	var seq: Array
	match style:
		"map":
			seq = [[0, 4, root], [8, 4, fifth]]
		"title":
			seq = [[0, 3, root], [4, 2, root + 12], [8, 3, fifth], [12, 2, root + 12]]
		_:
			seq = []
			for s in range(0, 16, 2):
				seq.append([s, 2, (root + 12) if (style == "boss" and s % 4 == 2) else (fifth if s == 12 else root)])
	for e in seq:
		_tone(buf, t0 + e[0] * step, e[1] * step * 0.9, freq(e[2]), "tri", 0.34, 0.5, false)


static func _arp_bar(buf: PackedFloat32Array, chord: String, style: String, t0: float, step: float, octave: int) -> void:
	var c := chord_notes(chord, 12 * (octave + 1))
	var every := 2 if style == "map" else 1
	for s in range(0, 16, every):
		var note: int = c[(s / every) % 3]
		_tone(buf, t0 + s * step, step * every * 0.7, freq(note), "pulse", 0.045 if style == "map" else 0.05, 0.125, false)


static func _drum_bar(buf: PackedFloat32Array, pattern: String, t0: float, step: float, style: String) -> void:
	var soft := 0.5 if style == "map" else 1.0
	for s in 16:
		var ch := pattern[s]
		var t := t0 + s * step
		match ch:
			"k":
				_kick(buf, t, 0.5 * soft)
			"s":
				_noise(buf, t, 0.12, 0.22 * soft, 0.35)
			"h":
				_noise(buf, t, 0.03, 0.07 * soft, 0.9)


## Ton mit kurzer Hüllkurve; vibrato für die Melodie
static func _tone(buf: PackedFloat32Array, t: float, dur: float, f: float, wave: String, vol: float, duty: float, vibrato: bool) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE)
	var phase := 0.0
	for i in n:
		var idx := start + i
		if idx >= buf.size():
			return
		var tt := float(i) / RATE
		var ff := f * (1.0 + (0.004 * sin(tt * 34.0) if vibrato and tt > 0.12 else 0.0))
		phase = fmod(phase + ff / RATE, 1.0)
		var s := 0.0
		if wave == "tri":
			s = 4.0 * absf(phase - 0.5) - 1.0
		else:
			s = 1.0 if phase < duty else -1.0
		var env := minf(1.0, tt / 0.005) * (1.0 - 0.35 * minf(1.0, tt / 0.25))
		var rel := minf(1.0, (n - i) / (0.02 * RATE))
		buf[idx] += s * vol * env * rel


static func _kick(buf: PackedFloat32Array, t: float, vol: float) -> void:
	var start := int(t * RATE)
	var n := int(0.14 * RATE)
	var phase := 0.0
	for i in n:
		var idx := start + i
		if idx >= buf.size():
			return
		var k := float(i) / n
		phase += (150.0 * pow(0.25, k * 2.0) + 40.0) / RATE
		buf[idx] += sin(phase * TAU) * vol * (1.0 - k) * (1.0 - k)


static func _noise(buf: PackedFloat32Array, t: float, dur: float, vol: float, bright: float) -> void:
	var start := int(t * RATE)
	var n := int(dur * RATE)
	var last := 0.0
	for i in n:
		var idx := start + i
		if idx >= buf.size():
			return
		var r := randf_range(-1.0, 1.0)
		# einfacher Tiefpass: je dunkler, desto mehr Glättung
		last = last + (r - last) * bright
		var k := float(i) / n
		buf[idx] += last * vol * (1.0 - k) * (1.0 - k)
