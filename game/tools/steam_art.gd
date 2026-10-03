extends Node
## Steam-Bilder (03.10.2026): Kapseln, Bibliothek und Community-Symbol aus unseren Sprites und der Silkscreen-Schrift.
## Jedes Bild wird in einer kleinen Pixel-Leinwand gezeichnet und dann ganzzahlig vergrößert (Steam-Größe = Basis × k).
## Aufruf (mit Fenster, headless rendert nichts):
##   Godot --path game res://tools/steam_art.tscn [-- --only=header]
## Ergebnis: assets/steam/<name>.png im Projektordner

const Art := preload("res://tools/steam_art_canvas.gd")

## [Dateiname, Layout, Basisbreite, Basishöhe, Faktor]
const ASSETS := [
	["header_capsule", "header", 460, 215, 2],        # 920 × 430
	["small_capsule", "small", 231, 87, 2],           # 462 × 174
	["main_capsule", "main", 616, 353, 2],            # 1232 × 706
	["vertical_capsule", "vertical", 374, 448, 2],    # 748 × 896
	["library_capsule", "libcap", 300, 450, 2],       # 600 × 900
	["library_header", "header", 460, 215, 2],        # 920 × 430
	["library_hero", "hero", 960, 310, 4],            # 3840 × 1240, ohne Text
	["library_logo", "logo", 640, 96, 2],             # 1280 × 192, durchsichtig
	["community_icon", "icon", 92, 92, 2],            # 184 × 184
]


func _ready() -> void:
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.trim_prefix("--only=")
	var dir := ProjectSettings.globalize_path("res://").path_join("../assets/steam")
	DirAccess.make_dir_recursive_absolute(dir)
	for a in ASSETS:
		if only != "" and a[1] != only and a[0] != only:
			continue
		var vp := SubViewport.new()
		vp.size = Vector2i(a[2], a[3])
		vp.transparent_bg = a[1] == "logo"
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		add_child(vp)
		var c: Node2D = Art.new()
		c.kind = a[1]
		c.aw = a[2]
		c.ah = a[3]
		vp.add_child(c)
		for i in 3:
			await RenderingServer.frame_post_draw
		var img := vp.get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		img.resize(a[2] * a[4], a[3] * a[4], Image.INTERPOLATE_NEAREST)
		if a[1] == "logo":
			# Steam: Bibliotheks-Logo 1280 px breit, durchsichtiger Rand
			var full := Image.create(1280, img.get_height(), false, Image.FORMAT_RGBA8)
			full.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i((1280 - img.get_width()) / 2, 0))
			img = full
		if a[1] == "header" or a[1] == "small" or a[1] == "main" or a[1] == "vertical" or a[1] == "libcap" or a[1] == "hero" or a[1] == "icon":
			img.convert(Image.FORMAT_RGB8)
		img.save_png(dir.path_join(a[0] + ".png"))
		print("%s: %d × %d" % [a[0], img.get_width(), img.get_height()])
		vp.queue_free()
	get_tree().quit()
