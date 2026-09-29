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
}

const FOES := [
	{"name": "Bugsy", "el": "Virus", "hp": 70, "move": 1.4, "atk": 2.4, "dmg": 10, "pat": ["row"], "spr": "bug", "loot": 10, "boss": false, "tele": false},
	{"name": "Glitchmotte", "el": "Elektro", "hp": 60, "move": 1.0, "atk": 2.0, "dmg": 14, "pat": ["cell"], "spr": "moth", "loot": 10, "boss": false, "tele": true},
	{"name": "Bytewurm", "el": "Virus", "hp": 90, "move": 1.6, "atk": 2.6, "dmg": 12, "pat": ["row", "col"], "spr": "wurm", "loot": 10, "boss": false, "tele": false},
	{"name": "Kernelmantis", "el": "Virus", "hp": 320, "move": 1.8, "atk": 2.2, "dmg": 16, "pat": ["row"], "spr": "mantis", "title": "Wächter des System-Kernels", "loot": 30, "boss": true, "tele": false},
	# --- Cache-Wiesen-Erweiterung 28.09.2026 (Index 4–6) ---
	{"name": "Chiffrekäfer", "el": "Code", "hp": 80, "move": 1.5, "atk": 2.5, "dmg": 12, "pat": ["cross"], "spr": "kaefer", "loot": 10, "boss": false, "tele": false},
	{"name": "Datenwespe", "el": "Virus", "hp": 50, "move": 0.8, "atk": 1.7, "dmg": 8, "pat": ["cell", "row", "cell"], "spr": "wespe", "loot": 10, "boss": false, "tele": false},
	{"name": "Glutraupe", "el": "Feuer", "hp": 115, "move": 2.2, "atk": 3.2, "dmg": 16, "pat": ["wall"], "spr": "raupe", "loot": 12, "boss": false, "tele": false},
	# --- Firewall-Vulkan (Index 7–10) ---
	{"name": "Glutmilbe", "el": "Feuer", "hp": 60, "move": 0.7, "atk": 1.6, "dmg": 9, "pat": ["cell", "cell", "row"], "spr": "milbe", "loot": 11, "boss": false, "tele": false},
	{"name": "Brandmauerassel", "el": "Code", "hp": 130, "move": 2.0, "atk": 3.0, "dmg": 15, "pat": ["col2"], "spr": "assel", "loot": 13, "boss": false, "tele": false},
	{"name": "Aschefalter", "el": "Feuer", "hp": 75, "move": 1.1, "atk": 2.4, "dmg": 10, "pat": ["lava", "cell"], "spr": "falter", "loot": 12, "boss": false, "tele": true},
	{"name": "Glutkernskarabäus", "el": "Feuer", "hp": 420, "move": 1.8, "atk": 2.1, "dmg": 17, "pat": ["row", "lava", "col"], "spr": "skarab", "title": "Glühendes Herz des Vulkans", "loot": 40, "boss": true, "tele": false, "minion": "lava"},
	# --- Viren-Sümpfe (Index 11–14) ---
	{"name": "Saugmücke", "el": "Virus", "hp": 65, "move": 0.8, "atk": 1.8, "dmg": 10, "pat": ["cell", "row"], "spr": "muecke", "loot": 13, "boss": false, "tele": false, "drain": true},
	{"name": "Panzerschnecke", "el": "Code", "hp": 140, "move": 2.6, "atk": 2.8, "dmg": 14, "pat": ["slime", "row"], "spr": "schnecke", "loot": 14, "boss": false, "tele": false},
	{"name": "Glitchblüte", "el": "Virus", "hp": 110, "move": 99.0, "atk": 2.2, "dmg": 13, "pat": ["cross", "pop", "cross"], "spr": "bluete", "loot": 14, "boss": false, "tele": false, "stationary": true},
	{"name": "Schwarmkönigin", "el": "Virus", "hp": 520, "move": 1.9, "atk": 2.0, "dmg": 18, "pat": ["row", "slime", "col", "pop"], "spr": "koenigin", "title": "Herrscherin der Viren-Sümpfe", "loot": 50, "boss": true, "tele": false, "minion": "mix", "drain": true},
]

## Zonen: Gegner-Pools (Indizes in FOES), Boss, Zähigkeit, Hintergrund. Zone 2 wird nach dem Boss von Zone 1 frei.
const ZONES := {
	"wiesen": {"name": "Cache-Wiesen", "bg": "wiesen", "boss": 3, "hp_mult": 1.0,
		"early": [0, 1, 5], "late": [0, 1, 2, 4, 5, 6], "elite": [2, 4, 6],
		"desc": "Grüne Datenwiesen. Das Startgebiet.", "unlock": ""},
	"vulkan": {"name": "Firewall-Vulkan", "bg": "vulkan", "boss": 10, "hp_mult": 1.25,
		"early": [7, 9, 5], "late": [7, 8, 9, 4, 6], "elite": [8, 6, 4],
		"desc": "Glühende Sicherheitsmauern. Wasser hat hier einen Vorteil.", "unlock": "wiesen"},
	"sumpf": {"name": "Viren-Sümpfe", "bg": "sumpf", "boss": 14, "hp_mult": 1.5,
		"early": [11, 12, 13], "late": [11, 12, 13, 8, 2, 6], "elite": [12, 13, 8],
		"desc": "Blubbernde Sümpfe voller Viren und Glitch-Sporen. Elektro hat hier einen Vorteil.", "unlock": "vulkan"},
}
const ZONE_ORDER := ["wiesen", "vulkan", "sumpf"]

## Gegner-Pools der Cache-Wiesen (Indizes in FOES); allgemein siehe ZONES
const POOL_EARLY := [0, 1, 5]
const POOL_LATE := [0, 1, 2, 4, 5, 6]
const POOL_ELITE := [2, 4, 6]

## Spielbare Linien (Baby-Werte). evo: Element der meistgespielten Chips → Rookie.
const MONS := {
	"Pixmiez": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Katze",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Heilpatch", "Glutball", "Firewall", "Virusspritzer", "Blitzcursor"],
		"passive": "Katzenreflex", "passive_desc": "Weicht dem ersten Treffer jedes Kampfes aus (ab Champion: den ersten zwei).",
		"trait": "Allrounder. Guter Einstieg.",
		"evo": {"Feuer": "Blazebit", "Code": "Firewallo", "Virus": "Virulina", "Elektro": "Prismiez"},
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
		"deck": ["Pixelstrahl", "Pixelstrahl", "Doppelklick", "Byteschlag", "Byteschlag", "Heilpatch", "Blitzcursor", "Firewall"],
		"passive": "Hasenhaken", "passive_desc": "Bewegt sich doppelt so schnell.",
		"trait": "Flink. Blitz-Angriffe treffen immer.",
		"evo": {"Elektro": "Blinki", "Code": "Screenshina"},
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
		"deck": ["Byteschlag", "Byteschlag", "Byteschlag", "Pixelstrahl", "Pixelstrahl", "Heilpatch", "Blitzcursor", "Firewall"],
		"passive": "Dickes Fell", "passive_desc": "Nimmt 25 % weniger Schaden.",
		"trait": "Tank. Viel HP, langsam, steckt viel weg.",
		"evo": {"Elektro": "Sonnbrumm", "Code": "Bärtron"},
	},
	"Kauzbit": {
		"hp": 90, "move": 0.12, "rech": 1.0, "el": "Code", "animal": "Robo-Eule",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Heilpatch", "Laserschuss", "Glutball"],
		"passive": "Eulenblick", "passive_desc": "Sieht Angriffe früher: Warnungen erscheinen 0,3 s eher.",
		"trait": "Robo-Eule mit Adleraugen.",
		"evo": {"Code": "Optikauz", "Feuer": "Raketauz"},
	},
	# --- Fusionen (Labor): Endstufe auf Champion-Niveau (+20 HP über die Stufe), keine weitere Evolution ---
	"Dampfbyte": {
		"hp": 95, "move": 0.14, "rech": 1.0, "el": "Feuer", "animal": "Welpe × Axolotl", "fusion": true,
		"deck": ["Glutball", "Glutball", "Wasserstrahl", "Wasserstrahl", "Flammenwelle", "Blubberschild", "Übertakten", "Eisfeld"],
		"passive": "Dampfhülle", "passive_desc": "Wer Dampfbyte trifft, fängt Feuer.",
		"trait": "Fusion aus Feuer und Wasser.", "evo": {},
	},
	"Wolkerich": {
		"hp": 115, "move": 0.18, "rech": 1.0, "el": "Wasser", "animal": "Axolotl × Hamster", "fusion": true,
		"deck": ["Blubberschild", "Blubberschild", "Wasserstrahl", "Wasserstrahl", "Mini-Bot", "Eisfeld", "Heilpatch", "Firewall"],
		"passive": "Wolkendecke", "passive_desc": "Startet jeden Kampf in einer Schutzblase (30 Schaden, 6 s).",
		"trait": "Fusion. Sehr zäh und gut geschützt.", "evo": {},
	},
	"Glyphel": {
		"hp": 90, "move": 0.12, "rech": 1.1, "el": "Elektro", "animal": "Hase × Hamster", "fusion": true,
		"deck": ["Blitzcursor", "Blitzcursor", "Mini-Bot", "Mini-Bot", "Defrag", "Heilpatch", "Firewall", "Pixelstrahl"],
		"passive": "Urwissen", "passive_desc": "Chips laden 10 % schneller, Defrag liegt schon im Deck.",
		"trait": "Fusion aus Strom und Erinnerung.", "evo": {},
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
	{"a": "Funkling", "b": "Tröpfel", "r": "Dampfbyte", "hint": "Feuer und Wasser ergeben … Dampf?"},
	{"a": "Tröpfel", "b": "Kekso", "r": "Wolkerich", "hint": "Ein Tropfen und ein Keks, der sich alles merkt, werden zu einer Wolke voller Daten."},
	{"a": "Lumi", "b": "Kekso", "r": "Glyphel", "hint": "Strom und Erinnerung schreiben uralten Code."},
	{"a": "Quakli", "b": "Pixmiez", "r": "Spukatz", "need_form": "Virulina", "hint": "Ein Giftfrosch und ein Kätzchen … aber nur, wenn die Katze selbst Gift im Blut hat."},
]
const FUSION_COST := 100

## Alle Formen: Sprite-Datei, Stufe (1 Baby, 2 Rookie, 3 Champion), Element, nächste Stufe
const FORMS := {
	"Pixmiez": {"spr": "pixi_32", "stage": 1, "el": "Neutral", "up": ""},
	"Funkling": {"spr": "funk_32", "stage": 1, "el": "Feuer", "up": ""},
	"Tröpfel": {"spr": "drop_32", "stage": 1, "el": "Wasser", "up": ""},
	"Blazebit": {"spr": "Blazebit_64", "stage": 2, "el": "Feuer", "up": "Glutluchs"},
	"Firewallo": {"spr": "Firewallo_64", "stage": 2, "el": "Code", "up": "Bollwerkatz"},
	"Virulina": {"spr": "Virulina_64", "stage": 2, "el": "Virus", "up": "Toxipanth"},
	"Prismiez": {"spr": "Prismiez_64", "stage": 2, "el": "Elektro", "up": "Prismalynx"},
	"Glutbyte": {"spr": "Glutbyte_64", "stage": 2, "el": "Feuer", "up": "Magmawulf"},
	"Overclocko": {"spr": "Overclocko_64", "stage": 2, "el": "Code", "up": "Turbowulf"},
	"Kaskadi": {"spr": "Kaskadi_64", "stage": 2, "el": "Wasser", "up": "Tsunamander"},
	"Pufferling": {"spr": "Pufferling_64", "stage": 2, "el": "Code", "up": "Panzerpuff"},
	"Frostbyte": {"spr": "Frostbyte_64", "stage": 2, "el": "Wasser", "up": "Glaziolotl"},
	"Glutluchs": {"spr": "Glutluchs_80", "stage": 3, "el": "Feuer", "up": "Pyrolynx"},
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
	"Screenshina": {"spr": "Screenshina_64", "stage": 2, "el": "Code", "up": "Holohas"},
	"Holohas": {"spr": "Holohas_80", "stage": 3, "el": "Code", "up": "Quantenhas"},
	"Quakli": {"spr": "Quakli_32", "stage": 1, "el": "Virus", "up": ""},
	"Virulurch": {"spr": "Virulurch_64", "stage": 2, "el": "Virus", "up": "Toxikröt"},
	"Hüpfbyte": {"spr": "Huepfbyte_64", "stage": 2, "el": "Code", "up": "Mechaquak"},
	"Mechaquak": {"spr": "Mechaquak_80", "stage": 3, "el": "Code", "up": "Gigaquak"},
	"Molchi": {"spr": "Molchi_32", "stage": 1, "el": "Virus", "up": ""},
	"Toxmolch": {"spr": "Toxmolch_64", "stage": 2, "el": "Virus", "up": "Sumpfdrak"},
	"Magmolch": {"spr": "Magmolch_64", "stage": 2, "el": "Feuer", "up": "Lavadrak"},
	"Brummbit": {"spr": "Brummbit_32", "stage": 1, "el": "Neutral", "up": ""},
	"Sonnbrumm": {"spr": "Sonnbrumm_64", "stage": 2, "el": "Elektro", "up": "Sonnenpranke"},
	"Bärtron": {"spr": "Baertron_64", "stage": 2, "el": "Code", "up": "Titanbrumm"},
	"Titanbrumm": {"spr": "Titanbrumm_80", "stage": 3, "el": "Code", "up": "Kolossbrumm"},
	"Kauzbit": {"spr": "Kauzbit_32", "stage": 1, "el": "Code", "up": ""},
	"Optikauz": {"spr": "Optikauz_64", "stage": 2, "el": "Code", "up": "Radarkauz"},
	"Raketauz": {"spr": "Raketauz_64", "stage": 2, "el": "Feuer", "up": "Phönixkauz"},
	"Radarkauz": {"spr": "Radarkauz_80", "stage": 3, "el": "Code", "up": "Orbitkauz"},
	"Dampfbyte": {"spr": "Dampfbyte_80", "stage": 3, "el": "Feuer", "up": ""},
	"Wolkerich": {"spr": "Wolkerich_80", "stage": 3, "el": "Wasser", "up": ""},
	"Glyphel": {"spr": "Glyphel_80", "stage": 3, "el": "Elektro", "up": ""},
	"Spukatz": {"spr": "Spukatz_80", "stage": 3, "el": "Virus", "up": ""},
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
	"Sonnenpranke": {"spr": "Sonnenpranke_80", "stage": 3, "el": "Elektro", "up": "Supernovabär"},
	"Phönixkauz": {"spr": "Phoenixkauz_80", "stage": 3, "el": "Feuer", "up": "Infernokauz"},
	# --- Ultras (96 px, Stufe 4, ab 80 Element-Chips) ---
	"Pyrolynx": {"spr": "Pyrolynx_96", "stage": 4, "el": "Feuer", "up": ""},
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
	"Quantenhas": {"spr": "Quantenhas_96", "stage": 4, "el": "Code", "up": ""},
	"Plasmahase": {"spr": "Plasmahase_96", "stage": 4, "el": "Elektro", "up": ""},
	"Miasmakröt": {"spr": "Miasmakroet_96", "stage": 4, "el": "Virus", "up": ""},
	"Gigaquak": {"spr": "Gigaquak_96", "stage": 4, "el": "Code", "up": ""},
	"Hydradrak": {"spr": "Hydradrak_96", "stage": 4, "el": "Virus", "up": ""},
	"Vulkandrak": {"spr": "Vulkandrak_96", "stage": 4, "el": "Feuer", "up": ""},
	"Supernovabär": {"spr": "Supernovabaer_96", "stage": 4, "el": "Elektro", "up": ""},
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
	"Blazebit": {"name": "Flammensprung", "el": "Feuer", "anim": "jump", "hits": [45], "burn": 4, "desc": "Brennender Sprung: 45 Schaden + Brand."},
	"Glutluchs": {"name": "Glutkrallen", "el": "Feuer", "anim": "jump", "hits": [30, 30], "burn": 6, "desc": "Zwei Flammenhiebe à 30 + langer Brand."},
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
	"Screenshina": {"name": "Abbild", "el": "Code", "anim": "self", "hits": [20], "decoy": 2, "decoy_t": 8.0, "desc": "Ein Abbild fängt die nächsten 2 Treffer ab (8 s), dazu 20 Schaden."},
	"Holohas": {"name": "Hologrammarmee", "el": "Code", "anim": "self", "hits": [30], "decoy": 3, "decoy_t": 10.0, "desc": "Hologramme fangen die nächsten 3 Treffer ab (10 s), dazu 30 Schaden."},
	"Quakli": {"name": "Zungenschlag", "el": "Virus", "anim": "row", "hits": [25], "pull": true, "poison": 4, "desc": "Zieht den Gegner direkt vor dich: 25 Schaden + Gift."},
	"Virulurch": {"name": "Giftwolke", "el": "Virus", "anim": "field", "hits": [20], "poison": 10, "desc": "Giftwolke über das ganze Gegnerfeld: 20 + sehr langes Gift."},
	"Hüpfbyte": {"name": "Datensprung", "el": "Code", "anim": "jump", "hits": [40], "stun": 1.5, "desc": "Springt auf den Gegner: 40 Schaden, betäubt 1,5 s."},
	"Mechaquak": {"name": "Kolbensprung", "el": "Code", "anim": "jump", "hits": [60], "stun": 2.0, "desc": "Kolben-Sprung: 60 Schaden, betäubt 2 s."},
	"Molchi": {"name": "Giftspucke", "el": "Virus", "anim": "row", "hits": [25], "poison": 4, "desc": "Gift, das immer trifft: 25 Schaden + Gift."},
	"Toxmolch": {"name": "Toxinregen", "el": "Virus", "anim": "field", "hits": [30], "poison": 8, "desc": "Giftregen übers ganze Gegnerfeld: 30 + langes Gift."},
	"Magmolch": {"name": "Lavastrom", "el": "Feuer", "anim": "row", "hits": [40], "burn": 4, "desc": "Lava über die Gegnerreihe: 40 Schaden + Brand."},
	"Brummbit": {"name": "Tatzenhieb", "el": "Neutral", "anim": "jump", "hits": [40], "knock": true, "desc": "Kräftiger Prankenschlag: 40 Schaden, stößt zurück."},
	"Sonnbrumm": {"name": "Sonnenumarmung", "el": "Elektro", "anim": "self", "hits": [30], "heal": 35, "desc": "Heilt 35 HP und trifft mit 30 Schaden."},
	"Bärtron": {"name": "Raketenfaust", "el": "Code", "anim": "row", "hits": [60], "stun": 1.0, "desc": "Mechanische Faust: 60 Schaden, betäubt 1 s."},
	"Titanbrumm": {"name": "Doppelraketenfaust", "el": "Code", "anim": "row", "hits": [45, 45], "stun": 1.5, "desc": "Zwei Raketenfäuste à 45, betäubt 1,5 s."},
	"Kauzbit": {"name": "Scanblick", "el": "Code", "anim": "self", "hits": [15], "scan": 3, "desc": "15 Schaden, deine nächsten 3 Treffer machen +50 %."},
	"Optikauz": {"name": "Laserblick", "el": "Code", "anim": "row", "hits": [50], "desc": "Laser aus den Linsenaugen: 50 Schaden."},
	"Raketauz": {"name": "Düsenangriff", "el": "Feuer", "anim": "field", "hits": [20, 20, 20], "burn": 4, "desc": "Drei Zielraketen à 20 + Brand."},
	"Radarkauz": {"name": "Zielerfassung", "el": "Code", "anim": "self", "hits": [30], "scan": 5, "desc": "30 Schaden, deine nächsten 5 Treffer machen +50 %."},
	"Dampfbyte": {"name": "Dampfexplosion", "el": "Wasser", "anim": "field", "hits": [30], "burn": 3, "stun": 1.0, "desc": "Heißer Dampf übers ganze Gegnerfeld: 30 + Brand, betäubt 1 s."},
	"Wolkerich": {"name": "Datenwolke", "el": "Wasser", "anim": "field", "hits": [15], "bubble": 60, "bubble_t": 6.0, "heal": 20, "desc": "Schutzblase (60, 6 s), heilt 20 HP und trifft das ganze Feld mit 15."},
	"Glyphel": {"name": "Urcode", "el": "Elektro", "anim": "self", "hits": [25], "recharge": true, "scan": 3, "desc": "Lädt alle Chips, 25 Schaden, die nächsten 3 Treffer +50 %."},
	"Toxipanth": {"name": "Giftsprung", "el": "Virus", "anim": "jump", "hits": [50], "poison": 8, "desc": "Lautloser Sprung: 50 Schaden + starkes Gift."},
	"Prismalynx": {"name": "Prismastrahl", "el": "Elektro", "anim": "field", "hits": [45], "heal": 30, "desc": "Regenbogenlicht übers ganze Feld: 45 Schaden, heilt 30 HP."},
	"Glaziolotl": {"name": "Gletscherwelle", "el": "Wasser", "anim": "field", "hits": [45], "stun": 3.0, "desc": "Eisige Flut übers ganze Feld: 45 Schaden, friert 3 s ein."},
	"Schattnager": {"name": "Schattenfalle", "el": "Virus", "anim": "self", "hits": [20], "replay": true, "mines": 3, "desc": "Backentasche, drei Virus-Minen und 20 Schaden."},
	"Glanzbacke": {"name": "Sonnenkeks", "el": "Elektro", "anim": "self", "hits": [20], "replay": true, "heal": 45, "desc": "Backentasche, heilt 45 HP und trifft mit 20."},
	"Strahlhase": {"name": "Blitzgewitter", "el": "Elektro", "anim": "field", "hits": [20, 20, 20, 20], "desc": "Vier Lichtblitze à 20."},
	"Toxikröt": {"name": "Seuchenwolke", "el": "Virus", "anim": "field", "hits": [30], "poison": 12, "desc": "Giftwolke übers ganze Feld: 30 + sehr langes Gift."},
	"Sumpfdrak": {"name": "Sumpfatem", "el": "Virus", "anim": "row", "hits": [45], "poison": 8, "desc": "Giftiger Atem über die Gegnerreihe: 45 + Gift."},
	"Lavadrak": {"name": "Lavaflut", "el": "Feuer", "anim": "field", "hits": [40], "burn": 6, "desc": "Lava übers ganze Gegnerfeld: 40 + langer Brand."},
	"Sonnenpranke": {"name": "Sonnenschlag", "el": "Elektro", "anim": "jump", "hits": [55], "heal": 40, "desc": "Leuchtender Prankenhieb: 55 Schaden, heilt 40 HP."},
	"Phönixkauz": {"name": "Phönixsturz", "el": "Feuer", "anim": "jump", "hits": [60], "burn": 6, "desc": "Flammender Sturzflug: 60 Schaden + Brand."},
	"Pyrolynx": {"name": "Dreischweif-Inferno", "el": "Feuer", "anim": "row", "hits": [28, 28, 28], "burn": 6, "desc": "Drei Feuerschweife über die Gegnerreihe à 28 + Brand."},
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
	"Quantenhas": {"name": "Quantenarmee", "el": "Code", "anim": "self", "hits": [40], "decoy": 4, "decoy_t": 12.0, "desc": "Vier Abbilder fangen Treffer ab (12 s), dazu 40 Schaden."},
	"Plasmahase": {"name": "Plasmasturm", "el": "Elektro", "anim": "field", "hits": [25, 25, 25, 25], "desc": "Vier Plasmablitze à 25."},
	"Miasmakröt": {"name": "Miasma", "el": "Virus", "anim": "field", "hits": [40], "poison": 16, "desc": "Giftnebel übers ganze Feld: 40 + extrem langes Gift."},
	"Gigaquak": {"name": "Gigasprung", "el": "Code", "anim": "jump", "hits": [85], "stun": 2.5, "desc": "Kolossaler Kolbensprung: 85 Schaden, betäubt 2,5 s."},
	"Hydradrak": {"name": "Dreikopfatem", "el": "Virus", "anim": "row", "hits": [30, 30, 30], "poison": 10, "desc": "Drei Köpfe speien Gift über die Reihe à 30 + Gift."},
	"Vulkandrak": {"name": "Eruption", "el": "Feuer", "anim": "field", "hits": [55], "burn": 8, "desc": "Ausbruch übers ganze Feld: 55 + langer Brand."},
	"Supernovabär": {"name": "Supernova", "el": "Elektro", "anim": "jump", "hits": [75], "heal": 55, "desc": "Strahlender Hieb: 75 Schaden, heilt 55 HP."},
	"Kolossbrumm": {"name": "Kolossfäuste", "el": "Code", "anim": "row", "hits": [55, 55], "stun": 2.0, "desc": "Zwei Kolossfäuste à 55, betäubt 2 s."},
	"Infernokauz": {"name": "Infernosturz", "el": "Feuer", "anim": "jump", "hits": [85], "burn": 8, "desc": "Flammender Sturzflug: 85 Schaden + langer Brand."},
	"Orbitkauz": {"name": "Orbitalschlag", "el": "Code", "anim": "self", "hits": [40], "scan": 8, "desc": "40 Schaden, deine nächsten 8 Treffer machen +50 %."},
	"Spukatz": {"name": "Spukschlag", "el": "Virus", "anim": "jump", "hits": [45], "poison": 6, "decoy": 1, "decoy_t": 6.0, "desc": "Geisterhafter Sprung: 45 + Gift, ein Abbild fängt den nächsten Treffer ab."},
}

const BEATS := {"Feuer": "Code", "Code": "Wasser", "Wasser": "Feuer"}
const RARITY_WEIGHT := {"Gewöhnlich": 6, "Selten": 3, "Episch": 1}


static func mult(a: String, d: String) -> float:
	if BEATS.get(a, "") == d:
		return 1.5
	if BEATS.get(d, "") == a:
		return 0.75
	if (a == "Elektro" and d == "Virus") or (a == "Virus" and d == "Elektro"):
		return 1.5
	return 1.0
