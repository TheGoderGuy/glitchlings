class_name GameData
extends RefCounted
## Spieldaten, übernommen aus prototype/index.html (CHIPS, FOES, MONS).

static var EL := {
	"Neutral": Color("#B8B0DD"), "Feuer": Color("#FF8A4C"), "Code": Color("#58D68D"),
	"Wasser": Color("#4CC3F0"), "Elektro": Color("#FFD84D"), "Virus": Color("#C77DFF"),
}

## Farben der Kampfansicht (dunkles Theme des Prototyps)
static var COL := {
	"bg": Color("#1E1738"), "bg2": Color("#171130"), "panel": Color("#2C2352"), "line": Color("#4A3E80"),
	"ink": Color("#F6F1FF"), "muted": Color("#B2A8D8"), "mint": Color("#6EE7C5"), "coral": Color("#FF7A93"),
	"sun": Color("#FFC83D"), "tileP": Color("#2A5A63"), "tileE": Color("#5A2F54"), "dark": Color("#120D24"),
}

const CHIPS := {
	"Pixelstrahl": {"cat": "Angriff", "el": "Neutral", "dmg": 20, "cd": 2.0, "rar": "Gewöhnlich", "desc": "Projektil über deine Reihe."},
	"Byteschlag": {"cat": "Angriff", "el": "Neutral", "dmg": 30, "cd": 1.5, "rar": "Gewöhnlich", "desc": "Nahkampf: vordere zwei Felder deiner Reihe."},
	"Firewall": {"cat": "Schild", "el": "Code", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Blockt den nächsten Treffer (4 s)."},
	"Bug-Mine": {"cat": "Falle", "el": "Virus", "dmg": 35, "cd": 3.0, "rar": "Selten", "desc": "Mine unter dem Gegner. Explodiert, wenn er darauf steht."},
	"Übertakten": {"cat": "Buff", "el": "Feuer", "dmg": 0, "cd": 6.0, "rar": "Selten", "desc": "Alle Chips laden 5 s doppelt so schnell."},
	"Glutball": {"cat": "Angriff", "el": "Feuer", "dmg": 45, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Schlägt 3 Felder vor dir ein: 45 im Zentrum, 20 daneben. Setzt Brand."},
	"Flammenwelle": {"cat": "Angriff", "el": "Feuer", "dmg": 25, "cd": 3.5, "rar": "Selten", "desc": "Trifft die ganze Spalte, in der der Gegner steht."},
	"Wasserstrahl": {"cat": "Angriff", "el": "Wasser", "dmg": 15, "cd": 2.0, "rar": "Gewöhnlich", "desc": "Projektil. Stößt den Gegner ein Feld zurück."},
	"Blubberschild": {"cat": "Schild", "el": "Wasser", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Blase absorbiert 30 Schaden (5 s)."},
	"Eisfeld": {"cat": "Feldeffekt", "el": "Wasser", "dmg": 0, "cd": 4.0, "rar": "Selten", "desc": "Friert den Gegner 2 s ein."},
	"Heilpatch": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 5.0, "rar": "Gewöhnlich", "desc": "Heilt sofort 25 HP."},
	"Blitzcursor": {"cat": "Angriff", "el": "Elektro", "dmg": 20, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Markiert den Gegner. Trifft nach 0,5 s garantiert."},
	"Mini-Bot": {"cat": "Beschwörung", "el": "Code", "dmg": 0, "cd": 6.0, "rar": "Selten", "desc": "Helfer: 6 s lang 5 Schaden pro Sekunde."},
	"Virusspritzer": {"cat": "Angriff", "el": "Virus", "dmg": 10, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Projektil. Vergiftet 4 s lang."},
	"Defrag": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 8.0, "rar": "Episch", "desc": "Lädt alle anderen Chips in der Hand sofort."},
	# --- Erweiterung 28.09.2026 ---
	"Doppelklick": {"cat": "Angriff", "el": "Neutral", "dmg": 12, "cd": 1.8, "rar": "Gewöhnlich", "desc": "Zwei schnelle Projektile über deine Reihe, je 12."},
	"Neustart": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 7.0, "rar": "Episch", "desc": "Heilt 15 HP und zieht eine komplett neue, sofort bereite Hand."},
	"Funkenregen": {"cat": "Angriff", "el": "Feuer", "dmg": 25, "cd": 3.0, "rar": "Selten", "desc": "Funken regnen aufs Gegnerfeld, einer trifft immer: 25 + Brand."},
	"Hitzeschild": {"cat": "Schild", "el": "Feuer", "dmg": 0, "cd": 5.0, "rar": "Gewöhnlich", "desc": "Blockt den nächsten Treffer (4 s) und setzt den Angreifer in Brand."},
	"Laserschuss": {"cat": "Angriff", "el": "Code", "dmg": 25, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Sofortiger Laser über deine Reihe: 25."},
	"Portscan": {"cat": "Buff", "el": "Code", "dmg": 0, "cd": 4.0, "rar": "Selten", "desc": "Deine nächsten 2 Treffer machen +50 % Schaden."},
	"Strudel": {"cat": "Feldeffekt", "el": "Wasser", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Der Gegner wird 3 s lang halb so schnell."},
	"Nebel": {"cat": "Schild", "el": "Wasser", "dmg": 0, "cd": 5.0, "rar": "Selten", "desc": "3 s lang verfehlen dich Angriffe mit 50 % Chance."},
	"Blitzlanze": {"cat": "Angriff", "el": "Elektro", "dmg": 30, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Trifft die Gegnerspalte, die deiner Spalte entspricht: 30."},
	"Blendgranate": {"cat": "Feldeffekt", "el": "Elektro", "dmg": 0, "cd": 5.0, "rar": "Selten", "desc": "Blendet den Gegner: sein laufender Angriff wird abgebrochen."},
	"Wurmloch": {"cat": "Falle", "el": "Virus", "dmg": 10, "cd": 3.0, "rar": "Selten", "desc": "Zieht den Gegner in deine Reihe: 10 Schaden."},
	"Kurzschluss": {"cat": "Angriff", "el": "Elektro", "dmg": 18, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Projektil: 18 Schaden, betäubt 0,5 s."},
	"Datenfresser": {"cat": "Angriff", "el": "Virus", "dmg": 15, "cd": 2.0, "rar": "Gewöhnlich", "desc": "Projektil: 15, doppelt gegen vergiftete Gegner."},
	# --- Erweiterung 29.09.2026: Kombos mit Zonen-Mechaniken und Modulen ---
	"Glutklinge": {"cat": "Angriff", "el": "Feuer", "dmg": 22, "cd": 1.6, "rar": "Gewöhnlich", "desc": "Nahkampf: vordere zwei Felder deiner Reihe, 22 + kurzer Brand."},
	"Feuersbrunst": {"cat": "Angriff", "el": "Feuer", "dmg": 30, "cd": 6.0, "rar": "Episch", "desc": "Ganzes Gegnerfeld: 30 + langer Brand. Doppelt, wenn er schon brennt."},
	"Flutwelle": {"cat": "Angriff", "el": "Wasser", "dmg": 28, "cd": 3.5, "rar": "Selten", "desc": "Welle über deine Reihe: 28, stößt den Gegner zurück."},
	"Frostsplitter": {"cat": "Angriff", "el": "Wasser", "dmg": 14, "cd": 2.2, "rar": "Gewöhnlich", "desc": "Projektil: 14, dreifach gegen eingefrorene oder langsame Gegner."},
	"Tsunami": {"cat": "Angriff", "el": "Wasser", "dmg": 35, "cd": 7.0, "rar": "Episch", "desc": "Trifft das ganze Gegnerfeld: 35 und friert 1,5 s ein."},
	"Kopierschutz": {"cat": "Schild", "el": "Code", "dmg": 15, "cd": 6.0, "rar": "Selten", "desc": "Blockt den nächsten Treffer (6 s) und wirft 15 Schaden zurück."},
	"Geschützturm": {"cat": "Beschwörung", "el": "Code", "dmg": 12, "cd": 7.0, "rar": "Selten", "desc": "Turm für 8 s: feuert alle 1,5 s einen Laser über deine Reihe (12)."},
	"Debugger": {"cat": "Angriff", "el": "Code", "dmg": 20, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Laser über deine Reihe: 20. Entfernt Lava, Schleim und Diener auf deiner Seite."},
	"Kettenblitz": {"cat": "Angriff", "el": "Elektro", "dmg": 15, "cd": 3.0, "rar": "Selten", "desc": "Trifft garantiert: 15, dann springt der Blitz zweimal nach (je 10)."},
	"Ladungsfeld": {"cat": "Buff", "el": "Elektro", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Lädt deine Signatur-Leiste um 25 %."},
	"Magnetfeld": {"cat": "Feldeffekt", "el": "Elektro", "dmg": 0, "cd": 3.5, "rar": "Gewöhnlich", "desc": "Zieht den Gegner in deine Spalte, betäubt 0,5 s. Kombo mit Blitzlanze!"},
	"Blackout": {"cat": "Feldeffekt", "el": "Elektro", "dmg": 0, "cd": 7.0, "rar": "Episch", "desc": "Stromausfall: Gegner 3 s betäubt, sein laufender Angriff fällt aus."},
	"Seuche": {"cat": "Feldeffekt", "el": "Virus", "dmg": 0, "cd": 4.0, "rar": "Selten", "desc": "Verdoppelt das Gift auf dem Gegner (min. 4 s)."},
	"Sporenfalle": {"cat": "Falle", "el": "Virus", "dmg": 15, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Mine unter dem Gegner: 15 Schaden und 6 s Gift."},
	"Parasit": {"cat": "Angriff", "el": "Virus", "dmg": 12, "cd": 3.0, "rar": "Selten", "desc": "Projektil: 12 Schaden, du heilst dich um genauso viel."},
	"Sprungantrieb": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Du weichst dem nächsten Treffer in den nächsten 2 s aus."},
	"Konter": {"cat": "Schild", "el": "Neutral", "dmg": 35, "cd": 4.0, "rar": "Selten", "desc": "Blockt einen Treffer in den nächsten 1,5 s und schlägt mit 35 zurück."},
}

const FOES := [
	{"name": "Bugsy", "el": "Virus", "hp": 70, "move": 1.4, "atk": 2.4, "dmg": 10, "pat": ["row"], "spr": "bug", "loot": 10, "boss": false, "tele": false},
	{"name": "Glitchmotte", "el": "Elektro", "hp": 60, "move": 1.0, "atk": 2.0, "dmg": 14, "pat": ["cell"], "spr": "moth", "loot": 10, "boss": false, "tele": true},
	{"name": "Bytewurm", "el": "Virus", "hp": 90, "move": 1.6, "atk": 2.6, "dmg": 12, "pat": ["row", "col"], "spr": "wurm", "loot": 10, "boss": false, "tele": false},
	{"name": "Kernelmantis", "el": "Virus", "hp": 380, "move": 1.8, "atk": 2.2, "dmg": 16, "pat": ["row"], "spr": "mantis", "title": "Wächter des System-Kernels", "loot": 30, "boss": true, "tele": false,
		"phase2": ["row", "cross", "col"], "phase3": ["cross", "col2", "row"],
		"specials": [{"shape": "x", "name": "Sensenkreuz"}, {"shape": "chase", "name": "Klingenhatz"}]},
	# --- Cache-Wiesen-Erweiterung 28.09.2026 (Index 4–6) ---
	{"name": "Chiffrekäfer", "el": "Code", "hp": 80, "move": 1.5, "atk": 2.5, "dmg": 12, "pat": ["cross"], "spr": "kaefer", "loot": 10, "boss": false, "tele": false},
	{"name": "Datenwespe", "el": "Virus", "hp": 50, "move": 0.8, "atk": 1.7, "dmg": 8, "pat": ["cell", "row", "cell"], "spr": "wespe", "loot": 10, "boss": false, "tele": false},
	{"name": "Glutraupe", "el": "Feuer", "hp": 115, "move": 2.2, "atk": 3.2, "dmg": 16, "pat": ["wall"], "spr": "raupe", "loot": 12, "boss": false, "tele": false},
	# --- Firewall-Vulkan (Index 7–10) ---
	{"name": "Glutmilbe", "el": "Feuer", "hp": 60, "move": 0.7, "atk": 1.6, "dmg": 9, "pat": ["cell", "cell", "row"], "spr": "milbe", "loot": 11, "boss": false, "tele": false},
	{"name": "Brandmauerassel", "el": "Code", "hp": 130, "move": 2.0, "atk": 3.0, "dmg": 15, "pat": ["col2"], "spr": "assel", "loot": 13, "boss": false, "tele": false},
	{"name": "Aschefalter", "el": "Feuer", "hp": 75, "move": 1.1, "atk": 2.4, "dmg": 10, "pat": ["lava", "cell"], "spr": "falter", "loot": 12, "boss": false, "tele": true},
	{"name": "Glutkernskarabäus", "el": "Feuer", "hp": 500, "move": 1.8, "atk": 2.1, "dmg": 17, "pat": ["row", "lava", "col"], "spr": "skarab", "title": "Glühendes Herz des Vulkans", "loot": 40, "boss": true, "tele": false, "minion": "lava",
		"phase2": ["col2", "lava", "row"], "phase3": ["wall", "lava", "cross"],
		"specials": [{"shape": "ring", "name": "Sonnenrad"}, {"shape": "safe1", "name": "Kernschmelze"}]},
	# --- Viren-Sümpfe (Index 11–14) ---
	{"name": "Saugmücke", "el": "Virus", "hp": 65, "move": 0.8, "atk": 1.8, "dmg": 10, "pat": ["cell", "row"], "spr": "muecke", "loot": 13, "boss": false, "tele": false, "drain": true},
	{"name": "Panzerschnecke", "el": "Code", "hp": 140, "move": 2.6, "atk": 2.8, "dmg": 14, "pat": ["slime", "row"], "spr": "schnecke", "loot": 14, "boss": false, "tele": false},
	{"name": "Glitchblüte", "el": "Virus", "hp": 110, "move": 99.0, "atk": 2.2, "dmg": 13, "pat": ["cross", "pop", "cross"], "spr": "bluete", "loot": 14, "boss": false, "tele": false, "stationary": true},
	{"name": "Schwarmkönigin", "el": "Virus", "hp": 600, "move": 1.9, "atk": 2.0, "dmg": 18, "pat": ["row", "slime", "col", "pop"], "spr": "koenigin", "title": "Herrscherin der Viren-Sümpfe", "loot": 50, "boss": true, "tele": false, "minion": "mix", "drain": true,
		"phase2": ["cross", "slime", "wall", "pop"], "phase3": ["col2", "pop", "cross", "slime"],
		"specials": [{"shape": "checker", "name": "Schwarmwelle"}, {"shape": "sweep", "name": "Stachelregen"}]},
	# --- NEST-Kern (Index 15–17) ---
	{"name": "Kerndrohne", "el": "Code", "hp": 120, "move": 1.4, "atk": 2.4, "dmg": 15, "pat": ["col2", "cross"], "spr": "drohne", "loot": 15, "boss": false, "tele": false},
	{"name": "Glitchspinne", "el": "Virus", "hp": 95, "move": 1.0, "atk": 2.2, "dmg": 14, "pat": ["wall", "cell", "row"], "spr": "spinne", "loot": 15, "boss": false, "tele": true},
	{"name": "Ur-Glitch", "el": "Virus", "hp": 800, "move": 1.7, "atk": 1.9, "dmg": 19, "pat": ["row", "cross", "col2", "wall"], "spr": "urglitch", "title": "Der Fehler, der den NEST zerbrach", "loot": 80, "boss": true, "tele": false, "minion": "shift", "shift": true, "final": true,
		"phase2": ["cross", "col2", "wall", "row"], "phase3": ["wall", "cross", "col2", "cross"],
		"specials": [{"shape": "ring", "name": "Systemabsturz"}, {"shape": "x", "name": "Kernfehler"}, {"shape": "safe1", "name": "Totalausfall"}, {"shape": "sweep", "name": "Datenlöschung"}]},
	# --- Ebenen-Wächter (30.09.2026, Index 18–24): Mini-Bosse am Ende von Ebene 1 und 2 jeder Zone ---
	# Großangriffe (specials) gibt es bei Wächtern von Anfang an, bei Bossen ab Phase 2.
	{"name": "Sprungschreck", "el": "Elektro", "hp": 230, "move": 1.3, "atk": 2.2, "dmg": 14, "pat": ["row", "cell", "col"], "spr": "sprungschreck",
		"title": "Der Springer der Datenwiesen", "loot": 22, "boss": true, "guard": true, "tele": true, "minion": "none",
		"phase2": ["cross", "row", "cell", "col"], "specials": [{"shape": "chase", "name": "Hüpfjagd"}]},
	{"name": "Dornwurz", "el": "Virus", "hp": 280, "move": 99.0, "atk": 2.3, "dmg": 15, "pat": ["cross", "row"], "spr": "dornwurz",
		"title": "Die Wurzel der Wiesen", "loot": 24, "boss": true, "guard": true, "tele": false, "stationary": true, "minion": "none", "pop_kind": "spore",
		"phase2": ["cross", "pop", "row", "col"], "specials": [{"shape": "checker", "name": "Dornenteppich"}]},
	{"name": "Schlackwurm", "el": "Feuer", "hp": 310, "move": 1.7, "atk": 2.3, "dmg": 16, "pat": ["lava", "row"], "spr": "schlackwurm",
		"title": "Er gräbt durch glühendes Gestein", "loot": 28, "boss": true, "guard": true, "tele": true, "minion": "none",
		"phase2": ["lava", "col2", "row"], "specials": [{"shape": "safe1", "name": "Magmageysir"}]},
	{"name": "Magmaskorp", "el": "Code", "hp": 360, "move": 1.7, "atk": 2.2, "dmg": 17, "pat": ["col", "row", "cell"], "spr": "magmaskorp",
		"title": "Der Stachel der Brandmauer", "loot": 30, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["col2", "cross", "lava", "row"], "specials": [{"shape": "pincer", "name": "Scherenzange"}]},
	{"name": "Schnappkelch", "el": "Virus", "hp": 380, "move": 99.0, "atk": 2.2, "dmg": 16, "pat": ["cross", "slime"], "spr": "schnappkelch",
		"title": "Der Hunger aus dem Sumpf", "loot": 32, "boss": true, "guard": true, "tele": false, "stationary": true, "minion": "none", "pop_kind": "spore",
		"phase2": ["cross", "slime", "row", "pop"], "specials": [{"shape": "pull", "name": "Fangschlund"}]},
	{"name": "Schlickkrake", "el": "Wasser", "hp": 430, "move": 1.5, "atk": 2.1, "dmg": 17, "pat": ["row", "slime", "col"], "spr": "schlickkrake",
		"title": "Herr des tiefen Schlicks", "loot": 34, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["col2", "slime", "wall"], "specials": [{"shape": "tentacle", "name": "Tentakelwirbel"}]},
	{"name": "Skolopendrox", "el": "Code", "hp": 480, "move": 1.2, "atk": 2.0, "dmg": 18, "pat": ["row", "col2"], "spr": "skolopendrox",
		"title": "Torwächter des Kerns", "loot": 40, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["wall", "cross", "col2"], "specials": [{"shape": "sweep", "name": "Segmentfeuer"}]},
]

## Zonen: Gegner-Pools (Indizes in FOES), Boss, Wächter je Ebene, Zähigkeit, Hintergrund. Zone 2 wird nach dem Boss von Zone 1 frei.
## Jede Zone hat 3 Ebenen à 5 Etagen (ZoneMap), die Finalzone nur 2 („levels“).
const ZONES := {
	"wiesen": {"name": "Cache-Wiesen", "bg": "wiesen", "boss": 3, "guards": [18, 19], "hp_mult": 1.0,
		"early": [0, 1, 5], "late": [0, 1, 2, 4, 5, 6], "elite": [2, 4, 6],
		"desc": "Grüne Datenwiesen. Das Startgebiet.", "unlock": ""},
	"vulkan": {"name": "Firewall-Vulkan", "bg": "vulkan", "boss": 10, "guards": [20, 21], "hp_mult": 1.25,
		"early": [7, 9, 5], "late": [7, 8, 9, 4, 6], "elite": [8, 6, 4],
		"desc": "Glühende Sicherheitsmauern. Wasser hat hier einen Vorteil.", "unlock": "wiesen"},
	"sumpf": {"name": "Viren-Sümpfe", "bg": "sumpf", "boss": 14, "guards": [22, 23], "hp_mult": 1.5,
		"early": [11, 12, 13], "late": [11, 12, 13, 8, 2, 6], "elite": [12, 13, 8],
		"desc": "Blubbernde Sümpfe voller Viren und Glitch-Sporen. Elektro hat hier einen Vorteil.", "unlock": "vulkan"},
	"kern": {"name": "NEST-Kern", "bg": "kern", "boss": 17, "guards": [24], "levels": 2, "hp_mult": 1.6, "final": true,
		"early": [15, 16, 12], "late": [15, 16, 8, 13, 4], "elite": [15, 16, 8, 12],
		"desc": "Das Herz des abgestürzten Servers. Kurz, hart – und am Ende wartet der Ur-Glitch.", "unlock": "sumpf"},
}
const ZONE_ORDER := ["wiesen", "vulkan", "sumpf", "kern"]
## Elemente, durch die der Ur-Glitch wechselt
const SHIFT_ELEMENTS := ["Virus", "Feuer", "Wasser", "Elektro", "Code"]

## Gegner-Pools der Cache-Wiesen (Indizes in FOES); allgemein siehe ZONES
const POOL_EARLY := [0, 1, 5]
const POOL_LATE := [0, 1, 2, 4, 5, 6]
const POOL_ELITE := [2, 4, 6]

## Spielbare Linien (Baby-Werte). evo: Element der meistgespielten Chips → Rookie.
const MONS := {
	"Pixmiez": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Katze",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Heilpatch", "Doppelklick", "Firewall", "Virusspritzer", "Blitzcursor"],
		"passive": "Katzenreflex", "passive_desc": "Weicht dem ersten Treffer jedes Kampfes aus (ab Champion: den ersten zwei).",
		"trait": "Allrounder. Guter Einstieg.",
		"evo": {"Code": "Firewallo", "Virus": "Virulina", "Elektro": "Prismiez"},
	},
	"Funkling": {
		"hp": 80, "move": 0.12, "rech": 1.1, "el": "Feuer", "animal": "Welpe",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Heilpatch", "Glutball", "Laserschuss"],
		"passive": "Übermut", "passive_desc": "Jeder 3. gespielte Chip halbiert die Ladezeit der anderen Chips auf der Hand.",
		"trait": "Wenig HP, Chips laden 10 % schneller.",
		"evo": {"Feuer": "Glutbyte", "Code": "Overclocko"},
	},
	"Tröpfel": {
		"hp": 120, "move": 0.18, "rech": 1.0, "el": "Wasser", "animal": "Axolotl",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Heilpatch", "Wasserstrahl", "Firewall"],
		"passive": "Regeneration", "passive_desc": "Heilt 1 HP pro Sekunde, wenn es 3 s nicht getroffen wurde (ab Champion: 2 HP).",
		"trait": "Viel HP, bewegt sich langsamer.",
		"evo": {"Wasser": "Kaskadi", "Code": "Pufferling"}, "ice": "Frostbyte",
	},
	# --- Weitere Linien aus dem Prototyp (Phase 3b, 29.09.2026), kommen aus Eiern ---
	"Kekso": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Hamster",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Heilpatch", "Bug-Mine", "Blitzcursor"],
		"passive": "Hamstern", "passive_desc": "25 % Chance: Ein gespielter Chip wird gehamstert und kommt gleich wieder.",
		"trait": "Hamstert Chips und legt Minen.",
		"evo": {"Virus": "Tracko", "Elektro": "Cachy"},
	},
	"Lumi": {
		"hp": 85, "move": 0.1, "rech": 1.05, "el": "Elektro", "animal": "Hase",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Doppelklick", "Byteschlag", "Byteschlag", "Heilpatch", "Blitzcursor", "Wasserstrahl"],
		"passive": "Hasenhaken", "passive_desc": "Bewegt sich doppelt so schnell.",
		"trait": "Flink. Blitz-Angriffe treffen immer.",
		"evo": {"Elektro": "Blinki", "Wasser": "Perlhopp"},
	},
	"Quakli": {
		"hp": 95, "move": 0.12, "rech": 1.0, "el": "Virus", "animal": "Frosch",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Heilpatch", "Virusspritzer", "Firewall"],
		"passive": "Giftbaut", "passive_desc": "Wer Quakli trifft, wird selbst vergiftet.",
		"trait": "Vergiftet Gegner und legt Minen.",
		"evo": {"Virus": "Virulurch", "Code": "Hüpfbyte"},
	},
	"Molchi": {
		"hp": 90, "move": 0.11, "rech": 1.0, "el": "Virus", "animal": "Salamander",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Heilpatch", "Virusspritzer", "Glutball"],
		"passive": "Giftdrüsen", "passive_desc": "Gift und Brand auf dem Gegner wirken 50 % stärker.",
		"trait": "Flinker Gift-Salamander.",
		"evo": {"Virus": "Toxmolch", "Feuer": "Magmolch"},
	},
	"Brummbit": {
		"hp": 140, "move": 0.2, "rech": 1.05, "el": "Neutral", "animal": "Bär",
		"deck": ["Byteschlag", "Byteschlag", "Byteschlag", "Pixelstrahl", "Pixelstrahl", "Heilpatch", "Virusspritzer", "Firewall"],
		"passive": "Dickes Fell", "passive_desc": "Nimmt 25 % weniger Schaden.",
		"trait": "Tank. Viel HP, langsam, steckt viel weg.",
		"evo": {"Virus": "Pilzbrumm", "Code": "Bärtron"},
	},
	"Kauzbit": {
		"hp": 90, "move": 0.12, "rech": 1.0, "el": "Code", "animal": "Robo-Eule",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Heilpatch", "Laserschuss", "Glutball"],
		"passive": "Eulenblick", "passive_desc": "Sieht Angriffe früher: Warnungen erscheinen 0,3 s eher.",
		"trait": "Robo-Eule mit Adleraugen.",
		"evo": {"Code": "Optikauz", "Feuer": "Raketauz"},
	},
	# --- Neue Linien 29.09.2026: Dachs und Waschbär ---
	"Buddli": {
		"hp": 115, "move": 0.15, "rech": 1.0, "el": "Neutral", "animal": "Dachs",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Byteschlag", "Heilpatch", "Glutball", "Blitzcursor"],
		"passive": "Furchtlos", "passive_desc": "Unter 30 % HP machen Chip-Treffer 50 % mehr Schaden.",
		"trait": "Zäh und furchtlos. Je knapper es wird, desto härter schlägt es zu.",
		"evo": {"Feuer": "Glimmdachs", "Elektro": "Zackdachs"},
	},
	"Maskli": {
		"hp": 90, "move": 0.11, "rech": 1.05, "el": "Neutral", "animal": "Waschbär",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Doppelklick", "Byteschlag", "Heilpatch", "Heilpatch", "Wasserstrahl", "Virusspritzer"],
		"passive": "Langfinger", "passive_desc": "Jeder 4. Chip-Treffer klaut Ladung: ein Chip auf der Hand ist sofort bereit.",
		"trait": "Flinker kleiner Dieb mit Maske.",
		"evo": {"Wasser": "Plätschbär", "Virus": "Klaubär"},
	},
	# --- Fusionen (Labor): Endstufe auf Champion-Niveau (+20 HP über die Stufe), keine weitere Evolution ---
	"Wolkerich": {
		"hp": 115, "move": 0.18, "rech": 1.0, "el": "Wasser", "animal": "Axolotl × Hamster", "fusion": true,
		"deck": ["Blubberschild", "Blubberschild", "Wasserstrahl", "Wasserstrahl", "Mini-Bot", "Eisfeld", "Heilpatch", "Firewall"],
		"passive": "Wolkendecke", "passive_desc": "Startet jeden Kampf in einer Schutzblase (30 Schaden, 6 s).",
		"trait": "Fusion. Sehr zäh und gut geschützt.", "evo": {},
	},
	"Wolperling": {
		"hp": 95, "move": 0.09, "rech": 1.05, "el": "Elektro", "animal": "Hase × Eule", "fusion": true,
		"deck": ["Blitzcursor", "Blitzcursor", "Kettenblitz", "Blitzlanze", "Magnetfeld", "Laserschuss", "Heilpatch", "Sprungantrieb"],
		"passive": "Mischwesen", "passive_desc": "Hase und Eule: bewegt sich doppelt so schnell und sieht Angriffe 0,3 s früher.",
		"trait": "Fusion. Ein Wolpertinger: flink und wachsam.", "evo": {},
	},
	"Schlummerbit": {
		"hp": 130, "move": 0.18, "rech": 1.0, "el": "Elektro", "animal": "Bär × Hamster", "fusion": true,
		"deck": ["Byteschlag", "Byteschlag", "Blitzcursor", "Kettenblitz", "Blendgranate", "Heilpatch", "Firewall", "Bug-Mine"],
		"passive": "Winterschlaf", "passive_desc": "Dickes Fell und volle Backen: nimmt 25 % weniger Schaden, 25 % Chance, einen Chip zu hamstern.",
		"trait": "Fusion. Schwebt schlafend durch seine Träume.", "evo": {},
	},
	"Pustebacke": {
		"hp": 90, "move": 0.1, "rech": 1.0, "el": "Virus", "animal": "Hamster × Frosch", "fusion": true,
		"deck": ["Virusspritzer", "Virusspritzer", "Sporenfalle", "Seuche", "Bug-Mine", "Pixelstrahl", "Heilpatch", "Sprungantrieb"],
		"passive": "Schwebegas", "passive_desc": "Schwebt: weicht 15 % der Treffer aus. Wer trifft, wird vergiftet.",
		"trait": "Fusion. Kugelrund, voller Giftgas und völlig chaotisch.", "evo": {},
	},
	"Spukatz": {
		"hp": 70, "move": 0.1, "rech": 1.0, "el": "Virus", "animal": "Katze × Frosch", "fusion": true,
		"deck": ["Virusspritzer", "Virusspritzer", "Bug-Mine", "Bug-Mine", "Blitzcursor", "Pixelstrahl", "Byteschlag", "Blubberschild"],
		"passive": "Spuk", "passive_desc": "Weicht 20 % aller Treffer aus.",
		"trait": "Fusion. Halb Geist, halb Katze.", "evo": {},
	},
}

## Fusionsrezepte (Linien, egal welche Stufe). need_form: eine bestimmte Form muss dabei sein.
const RECIPES := [
	{"a": "Kekso", "b": "Brummbit", "r": "Schlummerbit", "hint": "Zwei Winterschläfer, die gemeinsam träumen … vielleicht sogar von den Sternen."},
	{"a": "Tröpfel", "b": "Kekso", "r": "Wolkerich", "hint": "Ein Tropfen und ein Keks, der sich alles merkt, werden zu einer Wolke voller Daten."},
	{"a": "Lumi", "b": "Kauzbit", "r": "Wolperling", "hint": "Ein Hase, der fliegen will, und eine Eule, die hüpfen will. Aus alten Sagen bekannt."},
	{"a": "Kekso", "b": "Quakli", "r": "Pustebacke", "hint": "Volle Backen und eine Schallblase. Was passiert, wenn beide gleichzeitig aufpusten?"},
	{"a": "Quakli", "b": "Pixmiez", "r": "Spukatz", "need_form": "Virulina", "hint": "Ein Giftfrosch und ein Kätzchen … aber nur, wenn die Katze selbst Gift im Blut hat."},
]
const FUSION_COST := 100

## Alle Formen: Sprite-Datei, Stufe (1 Baby, 2 Rookie, 3 Champion), Element, nächste Stufe
const FORMS := {
	"Pixmiez": {"spr": "pixi_32", "stage": 1, "el": "Neutral", "up": ""},
	"Funkling": {"spr": "funk_32", "stage": 1, "el": "Feuer", "up": ""},
	"Tröpfel": {"spr": "drop_32", "stage": 1, "el": "Wasser", "up": ""},
	"Firewallo": {"spr": "Firewallo_64", "stage": 2, "el": "Code", "up": "Bollwerkatz"},
	"Virulina": {"spr": "Virulina_64", "stage": 2, "el": "Virus", "up": "Toxipanth"},
	"Prismiez": {"spr": "Prismiez_64", "stage": 2, "el": "Elektro", "up": "Prismalynx"},
	"Glutbyte": {"spr": "Glutbyte_64", "stage": 2, "el": "Feuer", "up": "Magmawulf"},
	"Overclocko": {"spr": "Overclocko_64", "stage": 2, "el": "Code", "up": "Turbowulf"},
	"Kaskadi": {"spr": "Kaskadi_64", "stage": 2, "el": "Wasser", "up": "Tsunamander"},
	"Pufferling": {"spr": "Pufferling_64", "stage": 2, "el": "Code", "up": "Panzerpuff"},
	"Frostbyte": {"spr": "Frostbyte_64", "stage": 2, "el": "Wasser", "up": "Glaziolotl"},
	"Bollwerkatz": {"spr": "Bollwerkatz_80", "stage": 3, "el": "Code", "up": "Bastionkatz"},
	"Magmawulf": {"spr": "Magmawulf_80", "stage": 3, "el": "Feuer", "up": "Glutfenrir"},
	"Turbowulf": {"spr": "Turbowulf_80", "stage": 3, "el": "Code", "up": "Hyperwulf"},
	"Tsunamander": {"spr": "Tsunamander_80", "stage": 3, "el": "Wasser", "up": "Leviamander"},
	"Panzerpuff": {"spr": "Panzerpuff_80", "stage": 3, "el": "Code", "up": "Kolosspuff"},
	"Kekso": {"spr": "Kekso_32", "stage": 1, "el": "Neutral", "up": ""},
	"Tracko": {"spr": "Tracko_64", "stage": 2, "el": "Virus", "up": "Schattnager"},
	"Cachy": {"spr": "Cachy_64", "stage": 2, "el": "Elektro", "up": "Glanzbacke"},
	"Lumi": {"spr": "Lumi_32", "stage": 1, "el": "Elektro", "up": ""},
	"Blinki": {"spr": "Blinki_64", "stage": 2, "el": "Elektro", "up": "Strahlhase"},
	"Quakli": {"spr": "Quakli_32", "stage": 1, "el": "Virus", "up": ""},
	"Virulurch": {"spr": "Virulurch_64", "stage": 2, "el": "Virus", "up": "Toxikröt"},
	"Hüpfbyte": {"spr": "Huepfbyte_64", "stage": 2, "el": "Code", "up": "Mechaquak"},
	"Mechaquak": {"spr": "Mechaquak_80", "stage": 3, "el": "Code", "up": "Gigaquak"},
	"Molchi": {"spr": "Molchi_32", "stage": 1, "el": "Virus", "up": ""},
	"Toxmolch": {"spr": "Toxmolch_64", "stage": 2, "el": "Virus", "up": "Sumpfdrak"},
	"Magmolch": {"spr": "Magmolch_64", "stage": 2, "el": "Feuer", "up": "Lavadrak"},
	"Brummbit": {"spr": "Brummbit_32", "stage": 1, "el": "Neutral", "up": ""},
	"Bärtron": {"spr": "Baertron_64", "stage": 2, "el": "Code", "up": "Titanbrumm"},
	"Titanbrumm": {"spr": "Titanbrumm_80", "stage": 3, "el": "Code", "up": "Kolossbrumm"},
	"Kauzbit": {"spr": "Kauzbit_32", "stage": 1, "el": "Code", "up": ""},
	"Optikauz": {"spr": "Optikauz_64", "stage": 2, "el": "Code", "up": "Radarkauz"},
	"Raketauz": {"spr": "Raketauz_64", "stage": 2, "el": "Feuer", "up": "Phönixkauz"},
	"Radarkauz": {"spr": "Radarkauz_80", "stage": 3, "el": "Code", "up": "Orbitkauz"},
	"Wolkerich": {"spr": "Wolkerich_80", "stage": 3, "el": "Wasser", "up": ""},
	"Spukatz": {"spr": "Spukatz_80", "stage": 3, "el": "Virus", "up": ""},
	"Wolperling": {"spr": "Wolperling_80", "stage": 3, "el": "Elektro", "up": ""},
	"Schlummerbit": {"spr": "Schlummerbit_80", "stage": 3, "el": "Elektro", "up": ""},
	# --- Dachs ---
	"Buddli": {"spr": "Buddli_32", "stage": 1, "el": "Neutral", "up": ""},
	"Glimmdachs": {"spr": "Glimmdachs_64", "stage": 2, "el": "Feuer", "up": "Magmadachs"},
	"Magmadachs": {"spr": "Magmadachs_80", "stage": 3, "el": "Feuer", "up": "Pyromeles"},
	"Pyromeles": {"spr": "Pyromeles_96", "stage": 4, "el": "Feuer", "up": ""},
	"Zackdachs": {"spr": "Zackdachs_64", "stage": 2, "el": "Elektro", "up": "Donnerdachs"},
	"Donnerdachs": {"spr": "Donnerdachs_80", "stage": 3, "el": "Elektro", "up": "Voltameles"},
	"Voltameles": {"spr": "Voltameles_96", "stage": 4, "el": "Elektro", "up": ""},
	# --- Waschbär ---
	"Maskli": {"spr": "Maskli_32", "stage": 1, "el": "Neutral", "up": ""},
	"Plätschbär": {"spr": "Plaetschbaer_64", "stage": 2, "el": "Wasser", "up": "Flutmaske"},
	"Flutmaske": {"spr": "Flutmaske_80", "stage": 3, "el": "Wasser", "up": "Hydrocyon"},
	"Hydrocyon": {"spr": "Hydrocyon_96", "stage": 4, "el": "Wasser", "up": ""},
	"Klaubär": {"spr": "Klaubaer_64", "stage": 2, "el": "Virus", "up": "Nachtmaske"},
	"Nachtmaske": {"spr": "Nachtmaske_80", "stage": 3, "el": "Virus", "up": "Virocyon"},
	"Virocyon": {"spr": "Virocyon_96", "stage": 4, "el": "Virus", "up": ""},
	"Pustebacke": {"spr": "Pustebacke_80", "stage": 3, "el": "Virus", "up": ""},
	# --- Neue Linien 29.09.2026: Brummbit Gift, Lumi Wasser ---
	"Pilzbrumm": {"spr": "Pilzbrumm_64", "stage": 2, "el": "Virus", "up": "Sporenpranke"},
	"Sporenpranke": {"spr": "Sporenpranke_80", "stage": 3, "el": "Virus", "up": "Myzelgrizz"},
	"Myzelgrizz": {"spr": "Myzelgrizz_96", "stage": 4, "el": "Virus", "up": ""},
	"Perlhopp": {"spr": "Perlhopp_64", "stage": 2, "el": "Wasser", "up": "Gischthase"},
	"Gischthase": {"spr": "Gischthase_80", "stage": 3, "el": "Wasser", "up": "Lunaflut"},
	"Lunaflut": {"spr": "Lunaflut_96", "stage": 4, "el": "Wasser", "up": ""},
	# --- Champions (PixelLab, 29.09.2026) ---
	"Toxipanth": {"spr": "Toxipanth_80", "stage": 3, "el": "Virus", "up": "Venomynx"},
	"Prismalynx": {"spr": "Prismalynx_80", "stage": 3, "el": "Elektro", "up": "Aurorlynx"},
	"Glaziolotl": {"spr": "Glaziolotl_80", "stage": 3, "el": "Wasser", "up": "Kryolotl"},
	"Schattnager": {"spr": "Schattnager_80", "stage": 3, "el": "Virus", "up": "Phantomnager"},
	"Glanzbacke": {"spr": "Glanzbacke_80", "stage": 3, "el": "Elektro", "up": "Stellarbacke"},
	"Strahlhase": {"spr": "Strahlhase_80", "stage": 3, "el": "Elektro", "up": "Plasmahase"},
	"Toxikröt": {"spr": "Toxikroet_80", "stage": 3, "el": "Virus", "up": "Miasmakröt"},
	"Sumpfdrak": {"spr": "Sumpfdrak_80", "stage": 3, "el": "Virus", "up": "Hydradrak"},
	"Lavadrak": {"spr": "Lavadrak_80", "stage": 3, "el": "Feuer", "up": "Vulkandrak"},
	"Phönixkauz": {"spr": "Phoenixkauz_80", "stage": 3, "el": "Feuer", "up": "Infernokauz"},
	# --- Ultras (96 px, Stufe 4, ab 80 Element-Chips) ---
	"Bastionkatz": {"spr": "Bastionkatz_96", "stage": 4, "el": "Code", "up": ""},
	"Venomynx": {"spr": "Venomynx_96", "stage": 4, "el": "Virus", "up": ""},
	"Aurorlynx": {"spr": "Aurorlynx_96", "stage": 4, "el": "Elektro", "up": ""},
	"Glutfenrir": {"spr": "Glutfenrir_96", "stage": 4, "el": "Feuer", "up": ""},
	"Hyperwulf": {"spr": "Hyperwulf_96", "stage": 4, "el": "Code", "up": ""},
	"Leviamander": {"spr": "Leviamander_96", "stage": 4, "el": "Wasser", "up": ""},
	"Kolosspuff": {"spr": "Kolosspuff_96", "stage": 4, "el": "Code", "up": ""},
	"Kryolotl": {"spr": "Kryolotl_96", "stage": 4, "el": "Wasser", "up": ""},
	"Phantomnager": {"spr": "Phantomnager_96", "stage": 4, "el": "Virus", "up": ""},
	"Stellarbacke": {"spr": "Stellarbacke_96", "stage": 4, "el": "Elektro", "up": ""},
	"Plasmahase": {"spr": "Plasmahase_96", "stage": 4, "el": "Elektro", "up": ""},
	"Miasmakröt": {"spr": "Miasmakroet_96", "stage": 4, "el": "Virus", "up": ""},
	"Gigaquak": {"spr": "Gigaquak_96", "stage": 4, "el": "Code", "up": ""},
	"Hydradrak": {"spr": "Hydradrak_96", "stage": 4, "el": "Virus", "up": ""},
	"Vulkandrak": {"spr": "Vulkandrak_96", "stage": 4, "el": "Feuer", "up": ""},
	"Kolossbrumm": {"spr": "Kolossbrumm_96", "stage": 4, "el": "Code", "up": ""},
	"Infernokauz": {"spr": "Infernokauz_96", "stage": 4, "el": "Feuer", "up": ""},
	"Orbitkauz": {"spr": "Orbitkauz_96", "stage": 4, "el": "Code", "up": ""},
}

const STAGE_NAMES := ["", "Baby", "Rookie", "Champion", "Ultra"]

## Prägung (gespielte Chips im Run), ab der die nächste Stufe erreicht wird
## Lebenszeit-Prägung (gespielte Chips über alle Runs): Rookie meist im ersten Run, Champion im zweiten/dritten
const EVO_AT := {2: 12, 3: 35, 4: 80}
## Die führende Richtung braucht so viele Chips Vorsprung vor der zweitbesten, sonst wartet die Evolution
const EVO_LEAD := 2

## Signatur-Attacken je Form. Treffer (hits) landen im Abstand von 0,15 s und treffen immer.
## anim: jump (Sprung zum Gegner), row (Welle über die Gegnerreihe), field (ganzes Gegnerfeld), self (auf sich selbst)
const SPECIALS := {
	"Pixmiez": {"name": "Pixelsprung", "el": "Neutral", "anim": "jump", "hits": [40], "desc": "Springt zum Gegner und kratzt: 40 Schaden."},
	"Firewallo": {"name": "Schildsprung", "el": "Code", "anim": "jump", "hits": [35], "shield": 4.0, "desc": "35 Schaden, landet mit Firewall-Schild (4 s)."},
	"Bollwerkatz": {"name": "Bollwerksprung", "el": "Code", "anim": "jump", "hits": [50], "stun": 1.0, "shield": 6.0, "desc": "Mecha-Sprung: 50 Schaden, betäubt 1 s, Firewall-Schild (6 s)."},
	"Virulina": {"name": "Giftkralle", "el": "Virus", "anim": "jump", "hits": [35], "poison": 6, "desc": "35 Schaden + starkes Gift."},
	"Prismiez": {"name": "Prismasprung", "el": "Elektro", "anim": "jump", "hits": [40], "heal": 20, "desc": "40 Schaden und heilt 20 HP."},
	"Funkling": {"name": "Funkenbiss", "el": "Feuer", "anim": "jump", "hits": [14, 14, 14], "desc": "Drei schnelle Funkenbisse à 14."},
	"Glutbyte": {"name": "Glutbiss", "el": "Feuer", "anim": "jump", "hits": [18, 18, 18], "burn": 4, "desc": "Drei glühende Bisse à 18 + Brand."},
	"Magmawulf": {"name": "Magmasturm", "el": "Feuer", "anim": "field", "hits": [20, 20, 20, 20], "burn": 6, "desc": "Vier Magma-Hiebe à 20 + langer Brand."},
	"Overclocko": {"name": "Überladung", "el": "Code", "anim": "self", "hits": [25], "recharge": true, "oc": 6.0, "desc": "Lädt alle Chips sofort, übertaktet 6 s, 25 Schaden."},
	"Turbowulf": {"name": "Turboschub", "el": "Code", "anim": "jump", "hits": [15, 15, 15], "recharge": true, "oc": 8.0, "desc": "Lädt alle Chips, übertaktet 8 s, rammt dreimal à 15."},
	"Tröpfel": {"name": "Blubberwelle", "el": "Wasser", "anim": "row", "hits": [30], "knock": true, "desc": "Welle: 30 Schaden, stößt zurück."},
	"Kaskadi": {"name": "Kaskadenflut", "el": "Wasser", "anim": "field", "hits": [35], "desc": "Flutet das ganze Gegnerfeld: 35 Schaden."},
	"Tsunamander": {"name": "Tsunami", "el": "Wasser", "anim": "field", "hits": [55], "stun": 1.5, "desc": "Riesenwelle: 55 Schaden, friert 1,5 s ein."},
	"Pufferling": {"name": "Aufblähen", "el": "Wasser", "anim": "self", "hits": [15], "bubble": 60, "bubble_t": 6.0, "desc": "Schutzblase (60 Schaden, 6 s) und 15 Schaden."},
	"Panzerpuff": {"name": "Panzerblase", "el": "Code", "anim": "field", "hits": [25], "bubble": 90, "bubble_t": 8.0, "desc": "Riesige Schutzblase (90, 8 s), 25 Schaden aufs ganze Feld."},
	"Frostbyte": {"name": "Frostwelle", "el": "Wasser", "anim": "row", "hits": [30], "stun": 2.5, "desc": "Eiswelle: 30 Schaden, friert 2,5 s ein."},
	"Kekso": {"name": "Backentasche", "el": "Neutral", "anim": "self", "hits": [], "replay": true, "desc": "Spuckt den zuletzt gespielten Chip kostenlos noch einmal aus (sonst 30 Schaden)."},
	"Tracko": {"name": "Keksfalle", "el": "Virus", "anim": "self", "hits": [], "replay": true, "mines": 2, "desc": "Backentasche und zwei Virus-Minen um den Gegner."},
	"Cachy": {"name": "Leuchtkeks", "el": "Elektro", "anim": "self", "hits": [], "replay": true, "heal": 30, "desc": "Backentasche und heilt 30 HP."},
	"Lumi": {"name": "Cursorblitz", "el": "Elektro", "anim": "field", "hits": [35], "desc": "Blitz, der immer trifft: 35 Schaden."},
	"Blinki": {"name": "Dreifachblitz", "el": "Elektro", "anim": "field", "hits": [22, 22, 22], "desc": "Drei Blitze à 22."},
	"Quakli": {"name": "Zungenschlag", "el": "Virus", "anim": "row", "hits": [25], "pull": true, "poison": 4, "desc": "Zieht den Gegner direkt vor dich: 25 Schaden + Gift."},
	"Virulurch": {"name": "Giftwolke", "el": "Virus", "anim": "field", "hits": [20], "poison": 10, "desc": "Giftwolke über das ganze Gegnerfeld: 20 + sehr langes Gift."},
	"Hüpfbyte": {"name": "Datensprung", "el": "Code", "anim": "jump", "hits": [40], "stun": 1.5, "desc": "Springt auf den Gegner: 40 Schaden, betäubt 1,5 s."},
	"Mechaquak": {"name": "Kolbensprung", "el": "Code", "anim": "jump", "hits": [60], "stun": 2.0, "desc": "Kolben-Sprung: 60 Schaden, betäubt 2 s."},
	"Molchi": {"name": "Giftspucke", "el": "Virus", "anim": "row", "hits": [25], "poison": 4, "desc": "Gift, das immer trifft: 25 Schaden + Gift."},
	"Toxmolch": {"name": "Toxinregen", "el": "Virus", "anim": "field", "hits": [30], "poison": 8, "desc": "Giftregen übers ganze Gegnerfeld: 30 + langes Gift."},
	"Magmolch": {"name": "Lavastrom", "el": "Feuer", "anim": "row", "hits": [40], "burn": 4, "desc": "Lava über die Gegnerreihe: 40 Schaden + Brand."},
	"Brummbit": {"name": "Tatzenhieb", "el": "Neutral", "anim": "jump", "hits": [40], "knock": true, "desc": "Kräftiger Prankenschlag: 40 Schaden, stößt zurück."},
	"Bärtron": {"name": "Raketenfaust", "el": "Code", "anim": "row", "hits": [60], "stun": 1.0, "desc": "Mechanische Faust: 60 Schaden, betäubt 1 s."},
	"Titanbrumm": {"name": "Doppelraketenfaust", "el": "Code", "anim": "row", "hits": [45, 45], "stun": 1.5, "desc": "Zwei Raketenfäuste à 45, betäubt 1,5 s."},
	"Kauzbit": {"name": "Scanblick", "el": "Code", "anim": "self", "hits": [15], "scan": 3, "desc": "15 Schaden, deine nächsten 3 Treffer machen +50 %."},
	"Optikauz": {"name": "Laserblick", "el": "Code", "anim": "row", "hits": [50], "desc": "Laser aus den Linsenaugen: 50 Schaden."},
	"Raketauz": {"name": "Düsenangriff", "el": "Feuer", "anim": "field", "hits": [20, 20, 20], "burn": 4, "desc": "Drei Zielraketen à 20 + Brand."},
	"Radarkauz": {"name": "Zielerfassung", "el": "Code", "anim": "self", "hits": [30], "scan": 5, "desc": "30 Schaden, deine nächsten 5 Treffer machen +50 %."},
	"Wolkerich": {"name": "Datenwolke", "el": "Wasser", "anim": "field", "hits": [15], "bubble": 60, "bubble_t": 6.0, "heal": 20, "desc": "Schutzblase (60, 6 s), heilt 20 HP und trifft das ganze Feld mit 15."},
	"Toxipanth": {"name": "Giftsprung", "el": "Virus", "anim": "jump", "hits": [50], "poison": 8, "desc": "Lautloser Sprung: 50 Schaden + starkes Gift."},
	"Prismalynx": {"name": "Prismastrahl", "el": "Elektro", "anim": "field", "hits": [45], "heal": 30, "desc": "Regenbogenlicht übers ganze Feld: 45 Schaden, heilt 30 HP."},
	"Glaziolotl": {"name": "Gletscherwelle", "el": "Wasser", "anim": "field", "hits": [45], "stun": 3.0, "desc": "Eisige Flut übers ganze Feld: 45 Schaden, friert 3 s ein."},
	"Schattnager": {"name": "Schattenfalle", "el": "Virus", "anim": "self", "hits": [20], "replay": true, "mines": 3, "desc": "Backentasche, drei Virus-Minen und 20 Schaden."},
	"Glanzbacke": {"name": "Sonnenkeks", "el": "Elektro", "anim": "self", "hits": [20], "replay": true, "heal": 45, "desc": "Backentasche, heilt 45 HP und trifft mit 20."},
	"Strahlhase": {"name": "Blitzgewitter", "el": "Elektro", "anim": "field", "hits": [20, 20, 20, 20], "desc": "Vier Lichtblitze à 20."},
	"Toxikröt": {"name": "Seuchenwolke", "el": "Virus", "anim": "field", "hits": [30], "poison": 12, "desc": "Giftwolke übers ganze Feld: 30 + sehr langes Gift."},
	"Sumpfdrak": {"name": "Sumpfatem", "el": "Virus", "anim": "row", "hits": [45], "poison": 8, "desc": "Giftiger Atem über die Gegnerreihe: 45 + Gift."},
	"Lavadrak": {"name": "Lavaflut", "el": "Feuer", "anim": "field", "hits": [40], "burn": 6, "desc": "Lava übers ganze Gegnerfeld: 40 + langer Brand."},
	"Phönixkauz": {"name": "Phönixsturz", "el": "Feuer", "anim": "jump", "hits": [60], "burn": 6, "desc": "Flammender Sturzflug: 60 Schaden + Brand."},
	"Bastionkatz": {"name": "Bastionssprung", "el": "Code", "anim": "jump", "hits": [70], "stun": 1.5, "shield": 8.0, "desc": "Festungssprung: 70 Schaden, betäubt 1,5 s, Firewall-Schild (8 s)."},
	"Venomynx": {"name": "Dreigiftschweif", "el": "Virus", "anim": "field", "hits": [25, 25, 25], "poison": 12, "desc": "Drei Giftschweife übers ganze Feld à 25 + sehr langes Gift."},
	"Aurorlynx": {"name": "Polarlicht", "el": "Elektro", "anim": "field", "hits": [60], "heal": 50, "desc": "Aurora übers ganze Feld: 60 Schaden, heilt 50 HP."},
	"Glutfenrir": {"name": "Fenrirbrand", "el": "Feuer", "anim": "jump", "hits": [45, 45], "burn": 8, "desc": "Zwei glühende Bisse à 45 + langer Brand."},
	"Hyperwulf": {"name": "Hyperschub", "el": "Code", "anim": "jump", "hits": [20, 20, 20, 20], "recharge": true, "oc": 10.0, "desc": "Lädt alle Chips, übertaktet 10 s, rammt viermal à 20."},
	"Leviamander": {"name": "Leviathanflut", "el": "Wasser", "anim": "field", "hits": [75], "stun": 2.0, "desc": "Gewaltige Flut: 75 Schaden, friert 2 s ein."},
	"Kolosspuff": {"name": "Kolossblase", "el": "Code", "anim": "field", "hits": [35], "bubble": 120, "bubble_t": 10.0, "desc": "Riesige Blase (120, 10 s) und 35 Schaden aufs ganze Feld."},
	"Kryolotl": {"name": "Absoluter Nullpunkt", "el": "Wasser", "anim": "field", "hits": [55], "stun": 4.0, "desc": "Alles gefriert: 55 Schaden, 4 s eingefroren."},
	"Phantomnager": {"name": "Phantomfalle", "el": "Virus", "anim": "self", "hits": [35], "replay": true, "mines": 4, "decoy": 2, "decoy_t": 8.0, "desc": "Backentasche, vier Minen, zwei Schatten fangen Treffer ab, 35 Schaden."},
	"Stellarbacke": {"name": "Sternenkeks", "el": "Elektro", "anim": "self", "hits": [30], "replay": true, "heal": 60, "desc": "Backentasche, heilt 60 HP und trifft mit 30."},
	"Plasmahase": {"name": "Plasmasturm", "el": "Elektro", "anim": "field", "hits": [25, 25, 25, 25], "desc": "Vier Plasmablitze à 25."},
	"Miasmakröt": {"name": "Miasma", "el": "Virus", "anim": "field", "hits": [40], "poison": 16, "desc": "Giftnebel übers ganze Feld: 40 + extrem langes Gift."},
	"Gigaquak": {"name": "Gigasprung", "el": "Code", "anim": "jump", "hits": [85], "stun": 2.5, "desc": "Kolossaler Kolbensprung: 85 Schaden, betäubt 2,5 s."},
	"Hydradrak": {"name": "Dreikopfatem", "el": "Virus", "anim": "row", "hits": [30, 30, 30], "poison": 10, "desc": "Drei Köpfe speien Gift über die Reihe à 30 + Gift."},
	"Vulkandrak": {"name": "Eruption", "el": "Feuer", "anim": "field", "hits": [55], "burn": 8, "desc": "Ausbruch übers ganze Feld: 55 + langer Brand."},
	"Kolossbrumm": {"name": "Kolossfäuste", "el": "Code", "anim": "row", "hits": [55, 55], "stun": 2.0, "desc": "Zwei Kolossfäuste à 55, betäubt 2 s."},
	"Infernokauz": {"name": "Infernosturz", "el": "Feuer", "anim": "jump", "hits": [85], "burn": 8, "desc": "Flammender Sturzflug: 85 Schaden + langer Brand."},
	"Orbitkauz": {"name": "Orbitalschlag", "el": "Code", "anim": "self", "hits": [40], "scan": 8, "desc": "40 Schaden, deine nächsten 8 Treffer machen +50 %."},
	"Wolperling": {"name": "Geweihblitz", "el": "Elektro", "anim": "jump", "hits": [30, 30], "stun": 1.0, "desc": "Flatternder Geweihstoß: 2 × 30, betäubt 1 s."},
	"Buddli": {"name": "Buddelstoß", "el": "Neutral", "anim": "jump", "hits": [35], "stun": 0.5, "desc": "Gräbt sich unter den Gegner und stößt hoch: 35, betäubt 0,5 s."},
	"Glimmdachs": {"name": "Glutgrabung", "el": "Feuer", "anim": "jump", "hits": [40], "burn": 4, "desc": "Glühende Krallen von unten: 40 + Brand."},
	"Magmadachs": {"name": "Magmaausbruch", "el": "Feuer", "anim": "field", "hits": [40], "burn": 6, "desc": "Gräbt eine Magmaader an: 40 aufs ganze Feld + langer Brand."},
	"Pyromeles": {"name": "Erdkernbrecher", "el": "Feuer", "anim": "jump", "hits": [60, 40], "burn": 8, "desc": "Bricht bis zum glühenden Kern durch: 60 + 40 + sehr langer Brand."},
	"Zackdachs": {"name": "Zackenstreif", "el": "Elektro", "anim": "row", "hits": [35], "stun": 0.5, "desc": "Blitz aus dem Gesichtsstreif über die Reihe: 35, betäubt 0,5 s."},
	"Donnerdachs": {"name": "Donnergrube", "el": "Elektro", "anim": "field", "hits": [25, 25], "stun": 1.0, "desc": "Donnerschlag aus der Tiefe: 2 × 25 aufs ganze Feld, betäubt 1 s."},
	"Voltameles": {"name": "Hochspannungsgraben", "el": "Elektro", "anim": "field", "hits": [30, 30, 30], "stun": 1.5, "desc": "Drei Blitzgräben übers ganze Feld: 3 × 30, betäubt 1,5 s."},
	"Maskli": {"name": "Taschendieb", "el": "Neutral", "anim": "self", "hits": [25], "recharge": true, "desc": "Klaut Ladung: alle Chips sofort bereit, dazu 25 Schaden."},
	"Plätschbär": {"name": "Waschgang", "el": "Wasser", "anim": "row", "hits": [30], "knock": true, "desc": "Schwall über die Reihe: 30, stößt zurück."},
	"Flutmaske": {"name": "Flutraubzug", "el": "Wasser", "anim": "field", "hits": [35], "stun": 1.5, "heal": 20, "desc": "Flutwelle übers ganze Feld: 35, friert 1,5 s ein, heilt 20 HP."},
	"Hydrocyon": {"name": "Sintflut-Coup", "el": "Wasser", "anim": "field", "hits": [30, 30], "stun": 2.0, "recharge": true, "desc": "2 × 30 aufs ganze Feld, friert 2 s ein und lädt alle Chips."},
	"Klaubär": {"name": "Giftgriff", "el": "Virus", "anim": "jump", "hits": [30], "poison": 6, "desc": "Blitzschneller Griff: 30 + Gift."},
	"Nachtmaske": {"name": "Schattenraub", "el": "Virus", "anim": "self", "hits": [40], "poison": 8, "decoy": 1, "decoy_t": 6.0, "desc": "40 + langes Gift, ein Schatten fängt den nächsten Treffer ab."},
	"Virocyon": {"name": "Datenraubzug", "el": "Virus", "anim": "field", "hits": [40], "poison": 12, "recharge": true, "desc": "Klaut alle Daten: 40 aufs ganze Feld, sehr langes Gift, lädt alle Chips."},
	"Schlummerbit": {"name": "Schlaflied", "el": "Elektro", "anim": "field", "hits": [20], "stun": 3.0, "heal": 30, "desc": "Ein Schlaflied übers ganze Feld: 20 Schaden, der Gegner schläft 3 s, du heilst 30 HP."},
	"Pustebacke": {"name": "Gasexplosion", "el": "Virus", "anim": "field", "hits": [15, 15], "poison": 10, "desc": "Platzt fast vor Gas: Giftwolke übers ganze Feld, 2 × 15 + langes Gift."},
	"Pilzbrumm": {"name": "Sporenwolke", "el": "Virus", "anim": "field", "hits": [20], "poison": 6, "desc": "Giftige Sporenwolke übers ganze Feld: 20 + Gift."},
	"Sporenpranke": {"name": "Giftpranke", "el": "Virus", "anim": "jump", "hits": [50], "poison": 8, "knock": true, "desc": "Pilzbesetzter Prankenhieb: 50 + langes Gift, stößt zurück."},
	"Myzelgrizz": {"name": "Myzelnetz", "el": "Virus", "anim": "field", "hits": [45], "poison": 12, "heal": 40, "desc": "Pilzgeflecht überzieht das Feld: 45 + sehr langes Gift, heilt 40 HP."},
	"Perlhopp": {"name": "Perlenschuss", "el": "Wasser", "anim": "row", "hits": [30], "knock": true, "desc": "Perlenblasen über die Reihe: 30, stößt zurück."},
	"Gischthase": {"name": "Gischtsprung", "el": "Wasser", "anim": "jump", "hits": [25, 25], "stun": 1.0, "desc": "Zwei Sprungtritte aus Gischt à 25, friert 1 s ein."},
	"Lunaflut": {"name": "Springflut", "el": "Wasser", "anim": "field", "hits": [35, 35], "stun": 2.0, "heal": 30, "desc": "Mondflut übers ganze Feld: 2 × 35, friert 2 s ein, heilt 30 HP."},
	"Spukatz": {"name": "Spukschlag", "el": "Virus", "anim": "jump", "hits": [45], "poison": 6, "decoy": 1, "decoy_t": 6.0, "desc": "Geisterhafter Sprung: 45 + Gift, ein Abbild fängt den nächsten Treffer ab."},
}

const BEATS := {"Feuer": "Code", "Code": "Wasser", "Wasser": "Feuer"}
const RARITY_WEIGHT := {"Gewöhnlich": 6, "Selten": 3, "Episch": 1}

## Module: passive Gegenstände, die nur für den laufenden Run gelten (Quelle: Elite, Händler, Modulkapsel).
## pic = Piktogramm (PICTOS), col = Farbe des Symbols
const MODULES := {
	"verstaerker": {"name": "Verstärker", "rar": "Gewöhnlich", "pic": "star", "col": "#FFC83D", "desc": "Chip-Treffer machen +3 Schaden."},
	"schnelllader": {"name": "Schnelllader", "rar": "Gewöhnlich", "pic": "gear", "col": "#6EE7C5", "desc": "Chips laden 15 % schneller."},
	"startsignal": {"name": "Startsignal", "rar": "Gewöhnlich", "pic": "bolt", "col": "#FFE45C", "desc": "Die Signatur-Leiste startet jeden Kampf zu einem Viertel gefüllt."},
	"panzerplatte": {"name": "Panzerplatte", "rar": "Gewöhnlich", "pic": "shield", "col": "#58B7FF", "desc": "Jeder Treffer gegen dich macht 2 Schaden weniger."},
	"sammler": {"name": "Sammler", "rar": "Gewöhnlich", "pic": "coin", "col": "#FFC83D", "desc": "+30 % Fragmente aus Kämpfen."},
	"lebensbit": {"name": "Lebensbit", "rar": "Gewöhnlich", "pic": "heart", "col": "#FF7A8A", "desc": "Nach jedem Sieg heilst du 8 HP zusätzlich."},
	"schleimschuhe": {"name": "Schleimschuhe", "rar": "Gewöhnlich", "pic": "boot", "col": "#7BD35A", "desc": "Schleim bremst dich nicht, Lava schadet dir nur halb so viel."},
	"rabattchip": {"name": "Rabattchip", "rar": "Gewöhnlich", "pic": "coin", "col": "#58D68D", "desc": "Beim Datenhändler ist alles 25 % billiger."},
	"ueberhitzer": {"name": "Überhitzer", "rar": "Selten", "pic": "flame", "col": "#FF8A4C", "desc": "Brand verursacht doppelten Schaden."},
	"giftkapsel": {"name": "Giftkapsel", "rar": "Selten", "pic": "skull", "col": "#C77DFF", "desc": "Gift verursacht 50 % mehr Schaden."},
	"kaeltekern": {"name": "Kältekern", "rar": "Selten", "pic": "snow", "col": "#8FD8FF", "desc": "Einfrieren und Betäuben halten 50 % länger."},
	"elementlinse": {"name": "Elementlinse", "rar": "Selten", "pic": "eye", "col": "#FF8FD8", "desc": "Element-Vorteil macht doppelten statt 1,5-fachen Schaden."},
	"dornenpanzer": {"name": "Dornenpanzer", "rar": "Selten", "pic": "spike", "col": "#58B7FF", "desc": "Wirst du getroffen, erleidet der Gegner 6 Schaden."},
	"reflexbooster": {"name": "Reflexbooster", "rar": "Selten", "pic": "arrow", "col": "#6EE7C5", "desc": "Du bewegst dich 25 % schneller."},
	"prisma": {"name": "Prisma", "rar": "Selten", "pic": "gem", "col": "#FFE45C", "desc": "Element-Chips prägen doppelt: Evolution kommt schneller."},
	"kondensator": {"name": "Kondensator", "rar": "Selten", "pic": "bolt", "col": "#4CC3F0", "desc": "Die Signatur-Leiste lädt 30 % schneller."},
	"notschild": {"name": "Notschild", "rar": "Selten", "pic": "shield", "col": "#8FD8FF", "desc": "Jeder Kampf beginnt mit einer Blase, die 20 Schaden abfängt."},
	"suchalgorithmus": {"name": "Suchalgorithmus", "rar": "Selten", "pic": "eye", "col": "#FFC83D", "desc": "Bei jeder Chipwahl ist mindestens ein seltener oder epischer Chip."},
	"backupkern": {"name": "Backup-Kern", "rar": "Episch", "pic": "heart", "col": "#FFC83D", "desc": "Einmal pro Run: Statt zu verlieren kämpfst du mit 30 % HP weiter."},
	"kritbit": {"name": "Kritbit", "rar": "Episch", "pic": "star", "col": "#FF5470", "desc": "20 % Chance auf doppelten Schaden."},
	"saugbit": {"name": "Saugbit", "rar": "Episch", "pic": "heart", "col": "#C77DFF", "desc": "Heilt 1 HP pro 10 Schaden, den du austeilst."},
	"echochip": {"name": "Echochip", "rar": "Episch", "pic": "gear", "col": "#FF8FD8", "desc": "Jeder 4. Chip wird doppelt ausgelöst."},
}
const MODULE_PRICE := {"Gewöhnlich": 45, "Selten": 70, "Episch": 100}
const MODULE_WEIGHT_ELITE := {"Gewöhnlich": 3, "Selten": 4, "Episch": 2}
## Piktogramme 6×6 für Modul-Symbole
const PICTOS := {
	"star": ["..##..", "..##..", "######", ".####.", ".#..#.", "#....#"],
	"gear": [".#..#.", "######", "##..##", "##..##", "######", ".#..#."],
	"bolt": ["...##.", "..##..", ".####.", "..##..", ".##...", ".#...."],
	"shield": ["######", "######", "######", ".####.", ".####.", "..##.."],
	"coin": [".####.", "##..##", "#.##.#", "#.##.#", "##..##", ".####."],
	"heart": ["##.##.", "######", "######", ".####.", "..##..", "......"],
	"boot": [".##...", ".##...", ".##...", ".####.", "######", "......"],
	"flame": ["..#...", ".##.#.", ".####.", "######", "######", ".####."],
	"skull": [".####.", "######", "#.##.#", "######", ".#.#..", "......"],
	"snow": ["#.#.#.", ".###..", "#####.", ".###..", "#.#.#.", "......"],
	"eye": ["......", ".####.", "##..##", "#.##.#", "##..##", ".####."],
	"spike": ["#...#.", ".#.#..", "..#...", ".#.#..", "#...#.", "......"],
	"arrow": ["..#...", "..##..", "######", "######", "..##..", "..#..."],
	"gem": ["..##..", ".####.", "######", ".####.", "..##..", "......"],
}


## Element, das gegen d besonders stark ist (für Hinweise)
static func strong_against(d: String) -> String:
	for a in BEATS:
		if BEATS[a] == d:
			return a
	return {"Virus": "Elektro", "Elektro": "Virus"}.get(d, "")


static func mult(a: String, d: String) -> float:
	if BEATS.get(a, "") == d:
		return 1.5
	if BEATS.get(d, "") == a:
		return 0.75
	if (a == "Elektro" and d == "Virus") or (a == "Virus" and d == "Elektro"):
		return 1.5
	return 1.0
