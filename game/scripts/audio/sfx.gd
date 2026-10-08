extends Node
## Platzhalter-Soundeffekte, zur Laufzeit synthetisiert (Chiptune-Stil, keine Lizenzfragen).
## Aufruf: Sfx.play("hit"). Später durch echte Sounds ersetzbar, die Namen bleiben.

const RATE := 22050
const VOICES := 10

var streams := {}
var players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		players.append(p)
	# Segmente: [Wellenform, Startfrequenz, Endfrequenz, Dauer, Lautstärke]
	_def("move", [["tri", 520, 640, 0.035, 0.25]])
	_def("shoot", [["sq", 950, 320, 0.09, 0.22]])
	_def("slash", [["noise", 3000, 800, 0.08, 0.3], ["sq", 300, 150, 0.05, 0.2]])
	_def("chip", [["sq", 660, 990, 0.06, 0.18]])
	_def("hit", [["noise", 1800, 400, 0.08, 0.35], ["sq", 220, 90, 0.06, 0.25]])
	_def("hit_big", [["noise", 2400, 200, 0.16, 0.45], ["sq", 160, 50, 0.12, 0.35]])
	_def("tick", [["tri", 300, 250, 0.04, 0.15]])
	_def("hurt", [["sq", 380, 110, 0.18, 0.3], ["noise", 900, 200, 0.08, 0.25]])
	_def("block", [["tri", 1300, 1300, 0.05, 0.3], ["tri", 1750, 1750, 0.07, 0.25]])
	_def("shield", [["tri", 500, 1100, 0.12, 0.25]])
	_def("heal", [["tri", 523, 523, 0.06, 0.3], ["tri", 659, 659, 0.06, 0.3], ["tri", 784, 784, 0.1, 0.3]])
	_def("dodge", [["tri", 900, 1900, 0.1, 0.3]])
	_def("warn", [["sq", 740, 740, 0.04, 0.1], ["silence", 0, 0, 0.03, 0], ["sq", 740, 740, 0.04, 0.1]])
	_def("special", [["saw", 180, 1400, 0.25, 0.25], ["noise", 3000, 300, 0.2, 0.35]])
	_def("pop", [["sq", 1250, 1250, 0.03, 0.15], ["silence", 0, 0, 0.02, 0], ["sq", 1560, 1560, 0.04, 0.15]])
	_def("pop_close", [["tri", 900, 1500, 0.07, 0.3]])
	_def("select", [["tri", 760, 760, 0.03, 0.2]])
	_def("confirm", [["sq", 523, 523, 0.05, 0.18], ["sq", 1046, 1046, 0.08, 0.18]])
	_def("back", [["sq", 700, 350, 0.08, 0.15]])
	_def("win", [["sq", 523, 523, 0.08, 0.2], ["sq", 659, 659, 0.08, 0.2], ["sq", 784, 784, 0.08, 0.2], ["sq", 1046, 1046, 0.25, 0.2]])
	_def("evolve", [["tri", 262, 262, 0.1, 0.3], ["tri", 330, 330, 0.1, 0.3], ["tri", 392, 392, 0.1, 0.3], ["tri", 523, 523, 0.1, 0.3], ["sq", 659, 659, 0.1, 0.2], ["sq", 784, 784, 0.1, 0.2], ["sq", 1046, 1046, 0.45, 0.22]])
	_def("strike", [["noise", 600, 2400, 0.07, 0.16]])
	_def("charge", [["saw", 120, 900, 1.5, 0.18]])
	_def("shift", [["noise", 400, 3000, 0.12, 0.3], ["sq", 200, 800, 0.1, 0.2], ["sq", 800, 300, 0.12, 0.2]])
	# Großangriff angekündigt (Sirene), Großangriff komplett ausgewichen (Überlastung), Boss-Phasenwechsel (Brüllen)
	_def("alarm", [["sq", 880, 620, 0.16, 0.16], ["sq", 880, 620, 0.16, 0.16], ["sq", 880, 620, 0.2, 0.16]])
	_def("overload", [["noise", 5000, 1200, 0.1, 0.3], ["sq", 1400, 200, 0.25, 0.2], ["tri", 1800, 2400, 0.12, 0.2]])
	_def("phase", [["noise", 300, 1500, 0.2, 0.4], ["saw", 90, 60, 0.4, 0.3]])
	# Konter-Treffer: harter Schlag mit hellem Nachklang
	_def("counter", [["noise", 3500, 500, 0.06, 0.45], ["sq", 1200, 1800, 0.06, 0.22], ["tri", 1800, 1800, 0.12, 0.2]])
	_def("lose", [["tri", 392, 392, 0.14, 0.3], ["tri", 330, 330, 0.14, 0.3], ["tri", 262, 262, 0.14, 0.3], ["tri", 196, 150, 0.4, 0.3]])


func play(name: String, pitch_jitter := 0.05) -> void:
	if not streams.has(name):
		return
	var p := players[_next]
	_next = (_next + 1) % VOICES
	p.stream = streams[name]
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()


func _def(name: String, segments: Array) -> void:
	streams[name] = _render(segments)


func _render(segments: Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	var phase := 0.0
	var noise_val := 0.0
	var noise_t := 0.0
	for seg in segments:
		var wave: String = seg[0]
		var f0: float = seg[1]
		var f1: float = seg[2]
		var dur: float = seg[3]
		var vol: float = seg[4]
		var n := int(dur * RATE)
		for i in n:
			var k := float(i) / n
			var f := f0 * pow(f1 / f0, k) if f0 > 0 and f1 > 0 else f0
			phase = fmod(phase + f / RATE, 1.0)
			var s := 0.0
			match wave:
				"sq":
					s = 1.0 if phase < 0.5 else -1.0
				"tri":
					s = 4.0 * absf(phase - 0.5) - 1.0
				"saw":
					s = 2.0 * phase - 1.0
				"noise":
					noise_t += f / RATE
					if noise_t >= 1.0:
						noise_t = fmod(noise_t, 1.0)
						noise_val = randf_range(-1.0, 1.0)
					s = noise_val
			# kurzer Anschlag, dann Ausklingen
			var env := minf(1.0, i / (0.004 * RATE)) * pow(1.0 - k, 1.6)
			var v := int(clampf(s * vol * env, -1.0, 1.0) * 32000.0)
			data.append(v & 0xFF)
			data.append((v >> 8) & 0xFF)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	return wav
