class_name Shot
extends RefCounted
## Screenshot-Modus für Tests und Review: godot --path game -- --shot=<pfad.png> --mode=<…>
## Messmodus (03.10.2026): godot --path game -- --bench=<sekunden> --mode=<…> [weitere Shot-Optionen]
## misst statt eines Screenshots die Bildzeiten in 1920 × 1080 ohne VSync und gibt sie aus.

static var bench_secs := 0.0


static func args() -> Dictionary:
	var shot := {}
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			shot.path = a.substr(7)
		elif a.begins_with("--bench="):
			bench_secs = float(a.substr(8))
			shot.path = ""
		elif a.begins_with("--mode="):
			shot.mode = a.substr(7)
		elif a.begins_with("--floor="):
			shot.floor = int(a.substr(8))
		elif a.begins_with("--sim="):
			shot.sim = float(a.substr(6))
		elif a.begins_with("--mon="):
			shot.mon = a.substr(6)
		elif a.begins_with("--form="):
			shot.form = a.substr(7)
		elif a.begins_with("--t="):
			shot.t = float(a.substr(4))
		elif a.begins_with("--foe="):
			shot.foe = int(a.substr(6))
		elif a.begins_with("--zone="):
			shot.zone = a.substr(7)
		elif a.begins_with("--event="):
			shot.event = a.substr(8)
		elif a.begins_with("--mods="):
			shot.mods = a.substr(7).split(",")
		elif a.begins_with("--tutstep="):
			shot.tutstep = a.substr(10)
		elif a == "--reveal":
			shot.reveal = true
		elif a.begins_with("--newmod="):
			shot.newmod = a.substr(9)
		elif a.begins_with("--level="):
			shot.level = int(a.substr(8))
		elif a.begins_with("--special="):
			shot.special = float(a.substr(10))
		elif a.begins_with("--choose="):
			shot.choose = a.substr(9)
		elif a.begins_with("--choices="):
			shot.choices = a.substr(10).split(",")
		elif a.begins_with("--deck="):
			shot.deck = a.substr(7).split(",")
		elif a.begins_with("--praeg="):
			# z. B. --praeg=Elektro:12,Wasser:11 (Evolutionsanzeige testen)
			shot.praeg = {}
			for kv in a.substr(8).split(","):
				shot.praeg[kv.get_slice(":", 0)] = int(kv.get_slice(":", 1))
		elif a.begins_with("--font="):
			shot.font = a.substr(7)
		elif a.begins_with("--guide="):
			shot.guide = int(a.substr(8))
		elif a.begins_with("--daytime="):
			shot.daytime = a.substr(10)
		elif a.begins_with("--protocol="):
			shot.protocol = int(a.substr(11))
		elif a == "--legendegg":
			shot.legendegg = true
		elif a == "--counter":
			shot.counter = true
		elif a == "--elite" or a == "--glitch":
			shot.nodetype = a.substr(2)
		elif a == "--welcome":
			shot.welcome = true
		elif a.begins_with("--anim="):
			shot.anim = a.substr(7)
		elif a.begins_with("--atkpose="):
			shot.atkpose = float(a.substr(10))
		elif a.begins_with("--chip="):
			shot.chip = a.substr(7)
		elif a.begins_with("--key="):
			# Tastaturbelegung nur für den Screenshot, z. B. --key=chip_1:Shift
			var ak := a.substr(6).split(":")
			InputSetup.overrides[ak[0]] = OS.find_keycode_from_string(ak[1])
			InputSetup.setup()
		elif a.begins_with("--lang="):
			shot.lang = a.substr(7)
		elif a == "--testbuild":
			shot.testbuild = true
		elif a == "--bonus":
			shot.bonus = true
		elif a == "--zones":
			shot.zones = true
		elif a == "--glitchnode":
			shot.glitchnode = true
		elif a == "--guard":
			shot.guard = true
		elif a == "--pops":
			shot.pops = true
		elif a.begins_with("--chain="):
			shot.chain = int(a.substr(8))
		elif a == "--area":
			shot.area = true
		elif a == "--lava":
			shot.lava = true
		elif a == "--pad":
			shot.pad = true
		elif a == "--ps":
			shot.pad = true
			shot.ps = true
	return shot if shot.has("path") else {}


static func save(node: Node, path: String) -> void:
	if bench_secs > 0:
		await bench(node, bench_secs)
		return
	for i in 3:
		await RenderingServer.frame_post_draw
	var img := node.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Screenshot gespeichert: ", path)
	node.get_tree().quit()


## Bildzeiten messen: 1920 × 1080 im Fenster, VSync aus, ohne Bildratenbremse. Im Kampf spielt ein einfacher
## Autopilot (Chips sofort einsetzen, zufällig ausweichen, HP auffüllen), damit Effekte und Gegner laufen.
static func bench(node: Node, secs: float) -> void:
	var tree := node.get_tree()
	var win := node.get_window()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	win.mode = Window.MODE_WINDOWED
	win.size = Vector2i(1920, 1080)
	var vp := win.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	# Screenshots frieren die Szene ein, für die Messung soll sie laufen
	var cur0 = node.get("current")
	if cur0 != null:
		cur0.set_process(true)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 60:
		await tree.process_frame
	var frames: Array = []
	var rcpu := 0.0
	var rgpu := 0.0
	var calls := 0.0
	var n := 0
	var t0 := Time.get_ticks_usec()
	var last := t0
	var act := 0.0
	# --mode=wechsel: alle 45 Bilder die Szene wechseln (Titel > Station > Karte > Kampf > Ergebnis), langsamste Bilder je Wechsel
	var swap: bool = Shot.args().get("mode", "") == "wechsel"
	var swap_n := 0
	var swap_step := 0
	var swap_max := {}
	var swap_name := ""
	const SWAPS := ["Titel", "Station", "Karte", "Kampf", "Ergebnis"]
	while (last - t0) / 1e6 < secs:
		await tree.process_frame
		var now := Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
		if frames[-1] > 1000.0 / 60.0:
			var cs = node.get("current")
			print("  langsam: %.1f ms bei %.1f s in %s (Render-CPU %.1f ms, GPU %.1f ms)" % [frames[-1], (now - t0) / 1e6, cs.get_script().resource_path.get_file() if cs != null else "?", RenderingServer.viewport_get_measured_render_time_cpu(vp), RenderingServer.viewport_get_measured_render_time_gpu(vp)])
		rcpu += RenderingServer.viewport_get_measured_render_time_cpu(vp)
		rgpu += RenderingServer.viewport_get_measured_render_time_gpu(vp)
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		n += 1
		if swap:
			if swap_name != "" and swap_n < 6:
				swap_max[swap_name] = maxf(swap_max.get(swap_name, 0.0), frames[-1])
			swap_n += 1
			if swap_n >= 45:
				swap_n = 0
				swap_name = SWAPS[swap_step % SWAPS.size()]
				match swap_step % SWAPS.size():
					0: node.show_title()
					1:
						var tc := Time.get_ticks_usec()
						node.show_station()
						if swap_step < 5:
							print("  Station aufbauen: %.1f ms" % ((Time.get_ticks_usec() - tc) / 1000.0))
					2:
						node.run = RunState.new("Pixmiez", 7)
						node.show_map()
					3:
						node.run.enter(node.run.next_choices()[0])
						node.run.current_node().type = "fight"
						node._enter_node()
					4: node.show_result(true)
				swap_step += 1
		var cur = node.get("current")
		if cur != null and cur.get("st") != null:
			var st = cur.st
			st.run.hp = st.run.max_hp
			act += frames[-1] / 1000.0
			if act > 0.25:
				act = 0.0
				st.move_player(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
				for k in st.hand.size():
					st.use_slot(k)
				if st.sp >= 100:
					st.use_special()
	var sorted: Array = frames.duplicate()
	sorted.sort()
	var avg := 0.0
	for x in frames:
		avg += x
	avg /= frames.size()
	var p99: float = sorted[int(sorted.size() * 0.99)]
	var over := frames.filter(func(x): return x > 1000.0 / 60.0).size()
	var cur1 = node.get("current")
	var foe: String = cur1.st.def.name if cur1 != null and cur1.get("st") != null else ""
	print("BENCH %s %s | Bilder %d | Schnitt %.2f ms (%.0f fps) | 99%% %.2f ms | max %.2f ms | über 16,7 ms: %d | Render-CPU %.2f ms | GPU %.2f ms | Zeichenaufrufe %.0f | %s" % [
		Shot.args().get("mode", "?"), foe, frames.size(), avg, 1000.0 / avg, p99, sorted[-1], over, rcpu / n, rgpu / n, calls / n, RenderingServer.get_video_adapter_name()])
	if swap:
		var parts: Array = []
		for k in SWAPS:
			parts.append("%s %.1f ms" % [k, swap_max.get(k, 0.0)])
		print("WECHSEL (langsamstes Bild der ersten 6 nach dem Wechsel, %d Wechsel): %s" % [swap_step, " | ".join(parts)])
	tree.quit()
