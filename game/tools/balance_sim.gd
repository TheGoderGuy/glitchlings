extends Node
## Balancing-Simulation (08.10.2026, Game-Design-Analyse): spielt komplette Runs mit dem „Mensch“-Bot
## (BattleBot.human()) und gibt je Zone Siegquote, Kampfdauer, Gegnerangriffe und HP-Verlust aus.
## Aufruf: godot --headless --path game res://tools/balance_sim.tscn [-- --runs=N --bot=human|perfect|counter --diff=0..3 --protocol=N --zones]
## Standard: ganze Reisen (alle Akte) je Startstufe; --zones: einzelne Zonen wie vor der Reise.
## Zielwerte stehen in vault/05 Produktion/Game-Design-Analyse 2026-10-08.md.

const STAGE_FOR_ZONE := {"wiesen": 1, "vulkan": 2, "see": 3, "sumpf": 3, "steppe": 4, "kern": 4}
const LINES := ["Pixmiez", "Funkling", "Tröpfel", "Kekso", "Lumi", "Quakli", "Molchi", "Brummbit", "Kauzbit", "Buddli", "Maskli", "Bachli", "Plapperli"]

var runs := 13
var bot_kind := "human"
var diff := 1
var protocol := 0


func _ready() -> void:
	SaveGame.persist = false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--runs="):
			runs = int(a.substr(7))
		elif a.begins_with("--bot="):
			bot_kind = a.substr(6)
		elif a.begins_with("--diff="):
			diff = int(a.substr(7))
		elif a.begins_with("--protocol="):
			protocol = int(a.substr(11))
		elif a.begins_with("--set="):
			# Balancing-Werte ausprobieren, z. B. --set=FOE_DMG:1.4 oder --set=ACT_HP:1,1.4,1.8,2.2
			var kv := a.substr(6).split(":")
			var v: Array = Array(kv[1].split(",")).map(func(x): return float(x))
			match kv[0]:
				"FOE_HP":
					GameData.FOE_HP = v[0]
				"BOSS_HP":
					GameData.BOSS_HP = v[0]
				"FOE_DMG":
					GameData.FOE_DMG = v[0]
				"FOE_TEMPO":
					GameData.FOE_TEMPO = v[0]
				"ACT_HP":
					GameData.ACT_HP = v
				"ACT_DMG":
					GameData.ACT_DMG = v
				_:
					push_error("Unbekannter Wert: " + kv[0])
			print("  %s = %s" % [kv[0], v])
	print("Bot %s · Schwierigkeit %d · Protokoll %d · %d Runs je Zeile" % [bot_kind, diff, protocol, runs])
	if OS.get_cmdline_user_args().has("--zones"):
		for z in GameData.ZONE_ORDER:
			print(BalanceSim.zone_line(z, BalanceSim.run_zone(z, STAGE_FOR_ZONE[z], runs, bot_kind, diff, protocol)))
	else:
		# Reise: frisches Baby (erster Run), Rookie/Champion/Ultra mit passender Lebenszeit-Prägung
		var stages := [1, 2, 3, 4]
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--stage="):
				stages = [int(a.substr(8))]
		var names := {1: "Baby (neu)", 2: "Rookie", 3: "Champion", 4: "Ultra"}
		for st in stages:
			print(BalanceSim.journey_line(names[st], BalanceSim.run_journey(st, runs, bot_kind, diff, protocol, 0 if st == 1 else GameData.EVO_AT[st])))
	get_tree().quit()
