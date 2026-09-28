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
		elif a.begins_with("--room="):
			shot.room = int(a.substr(7))
		elif a.begins_with("--sim="):
			shot.sim = float(a.substr(6))
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
