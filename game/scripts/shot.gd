class_name Shot
extends RefCounted
## Screenshot-Modus für Tests und Review: godot --path game -- --shot=<pfad.png> --mode=<…>


static func args() -> Dictionary:
	var shot := {}
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			shot.path = a.substr(7)
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
		elif a.begins_with("--font="):
			shot.font = a.substr(7)
		elif a == "--glitchnode":
			shot.glitchnode = true
		elif a == "--guard":
			shot.guard = true
		elif a == "--pops":
			shot.pops = true
		elif a == "--lava":
			shot.lava = true
		elif a == "--pad":
			shot.pad = true
	return shot if shot.has("path") else {}


static func save(node: Node, path: String) -> void:
	for i in 3:
		await RenderingServer.frame_post_draw
	var img := node.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Screenshot gespeichert: ", path)
	node.get_tree().quit()
