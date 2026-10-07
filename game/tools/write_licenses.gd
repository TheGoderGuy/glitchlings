extends SceneTree
## Schreibt tools/LIZENZEN.txt: Schriften (SIL OFL), Godot Engine (MIT) und alle Drittbibliotheken der Engine.
## Godot verlangt, dass seine Lizenz mit dem Spiel ausgeliefert wird; die Build-Skripte kopieren die Datei mit.
## Aufruf (nach jedem Godot-Update neu): godot --headless --path game --script res://tools/write_licenses.gd


func _init() -> void:
	var out := PackedStringArray()
	out.append("GLITCHLINGS – Lizenzen und Danksagungen")
	out.append("=======================================")
	out.append("")
	out.append("Glitchlings © 2026 TheGoderGuy. Alle Rechte vorbehalten.")
	out.append("Monster, Gegner und Requisiten wurden mit PixelLab (pixellab.ai) erstellt.")
	out.append("")
	out.append("")
	out.append("SCHRIFTEN (SIL Open Font License 1.1)")
	out.append("-------------------------------------")
	out.append("Silkscreen von Jason Kottke")
	out.append("Pixeloid Sans von GGBotNet")
	out.append("")
	for f in ["res://assets/fonts/OFL.txt", "res://assets/fonts/Pixeloid-OFL.txt"]:
		out.append(FileAccess.get_file_as_string(f).strip_edges())
		out.append("")
		out.append("")
	out.append("GODOT ENGINE")
	out.append("------------")
	out.append("Dieses Spiel verwendet die Godot Engine, verfügbar unter der folgenden Lizenz:")
	out.append("")
	out.append(Engine.get_license_text().strip_edges())
	out.append("")
	out.append("")
	out.append("DRITTKOMPONENTEN DER GODOT ENGINE")
	out.append("---------------------------------")
	for c in Engine.get_copyright_info():
		out.append("- %s" % c.name)
		for part in c.parts:
			for cr in part.copyright:
				out.append("    © %s" % cr)
			out.append("    Lizenz: %s" % part.license)
	out.append("")
	out.append("")
	var lic: Dictionary = Engine.get_license_info()
	var names := lic.keys()
	names.sort()
	for n in names:
		out.append("Lizenz: %s" % n)
		out.append("")
		out.append(String(lic[n]).strip_edges())
		out.append("")
		out.append("")
	var path := ProjectSettings.globalize_path("res://tools/LIZENZEN.txt")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("\n".join(out))
	f.close()
	print("geschrieben: ", path, " (", out.size(), " Zeilen)")
	quit()
