class_name GameData
extends RefCounted
## Spieldaten, übernommen aus prototype/index.html (CHIPS, FOES, MONS).

static var EL := {
	"Neutral": Color("#B8B0DD"), "Feuer": Color("#FF8A4C"), "Code": Color("#58D68D"),
	"Wasser": Color("#4CC3F0"), "Licht": Color("#FFD84D"), "Virus": Color("#C77DFF"),
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
	"Heilpatch": {"cat": "Buff", "el": "Licht", "dmg": 0, "cd": 5.0, "rar": "Gewöhnlich", "desc": "Heilt sofort 25 HP."},
	"Blitzcursor": {"cat": "Angriff", "el": "Licht", "dmg": 20, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Markiert den Gegner. Trifft nach 0,5 s garantiert."},
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
	"Lichtlanze": {"cat": "Angriff", "el": "Licht", "dmg": 30, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Trifft die Gegnerspalte, die deiner Spalte entspricht: 30."},
	"Blendgranate": {"cat": "Feldeffekt", "el": "Licht", "dmg": 0, "cd": 5.0, "rar": "Selten", "desc": "Blendet den Gegner: sein laufender Angriff wird abgebrochen."},
	"Wurmloch": {"cat": "Falle", "el": "Virus", "dmg": 10, "cd": 3.0, "rar": "Selten", "desc": "Zieht den Gegner in deine Reihe: 10 Schaden."},
	"Datenfresser": {"cat": "Angriff", "el": "Virus", "dmg": 15, "cd": 2.0, "rar": "Gewöhnlich", "desc": "Projektil: 15, doppelt gegen vergiftete Gegner."},
}

const FOES := [
	{"name": "Bugsy", "el": "Virus", "hp": 70, "move": 1.4, "atk": 2.4, "dmg": 10, "pat": ["row"], "spr": "bug", "loot": 10, "boss": false, "tele": false},
	{"name": "Glitchmotte", "el": "Licht", "hp": 60, "move": 1.0, "atk": 2.0, "dmg": 14, "pat": ["cell"], "spr": "moth", "loot": 10, "boss": false, "tele": true},
	{"name": "Spamlet", "el": "Virus", "hp": 90, "move": 1.6, "atk": 2.6, "dmg": 12, "pat": ["row", "col"], "spr": "spam", "loot": 10, "boss": false, "tele": false},
	{"name": "Pop-Up-Tyrann", "el": "Virus", "hp": 320, "move": 1.8, "atk": 2.2, "dmg": 16, "pat": ["row"], "spr": "boss", "loot": 30, "boss": true, "tele": false},
	# --- Cache-Wiesen-Erweiterung 28.09.2026 (Index 4–6) ---
	{"name": "Captchakäfer", "el": "Code", "hp": 80, "move": 1.5, "atk": 2.5, "dmg": 12, "pat": ["cross"], "spr": "captcha", "loot": 10, "boss": false, "tele": false},
	{"name": "Spamwespe", "el": "Virus", "hp": 50, "move": 0.8, "atk": 1.7, "dmg": 8, "pat": ["cell", "row", "cell"], "spr": "wespe", "loot": 10, "boss": false, "tele": false},
	{"name": "Ladebalkenraupe", "el": "Feuer", "hp": 115, "move": 2.2, "atk": 3.2, "dmg": 16, "pat": ["wall"], "spr": "raupe", "loot": 12, "boss": false, "tele": false},
	# --- Firewall-Vulkan (Index 7–10) ---
	{"name": "Glutmilbe", "el": "Feuer", "hp": 60, "move": 0.7, "atk": 1.6, "dmg": 9, "pat": ["cell", "cell", "row"], "spr": "milbe", "loot": 11, "boss": false, "tele": false},
	{"name": "Brandmauerassel", "el": "Code", "hp": 130, "move": 2.0, "atk": 3.0, "dmg": 15, "pat": ["col2"], "spr": "assel", "loot": 13, "boss": false, "tele": false},
	{"name": "Aschefalter", "el": "Feuer", "hp": 75, "move": 1.1, "atk": 2.4, "dmg": 10, "pat": ["lava", "cell"], "spr": "falter", "loot": 12, "boss": false, "tele": true},
	{"name": "Glutkernskarabäus", "el": "Feuer", "hp": 420, "move": 1.8, "atk": 2.1, "dmg": 17, "pat": ["row", "lava", "col"], "spr": "skarab", "loot": 40, "boss": true, "tele": false, "minion": "lava"},
]

## Zonen: Gegner-Pools (Indizes in FOES), Boss, Zähigkeit, Hintergrund. Zone 2 wird nach dem Boss von Zone 1 frei.
const ZONES := {
	"wiesen": {"name": "Cache-Wiesen", "bg": "wiesen", "boss": 3, "hp_mult": 1.0,
		"early": [0, 1, 5], "late": [0, 1, 2, 4, 5, 6], "elite": [2, 4, 6],
		"desc": "Grüne Datenwiesen. Das Startgebiet.", "unlock": ""},
	"vulkan": {"name": "Firewall-Vulkan", "bg": "vulkan", "boss": 10, "hp_mult": 1.25,
		"early": [7, 9, 5], "late": [7, 8, 9, 4, 6], "elite": [8, 6, 4],
		"desc": "Glühende Sicherheitsmauern. Wasser hat hier einen Vorteil.", "unlock": "wiesen"},
}
const ZONE_ORDER := ["wiesen", "vulkan"]

## Gegner-Pools der Cache-Wiesen (Indizes in FOES); allgemein siehe ZONES
const POOL_EARLY := [0, 1, 5]
const POOL_LATE := [0, 1, 2, 4, 5, 6]
const POOL_ELITE := [2, 4, 6]

## Spielbare Linien (Baby-Werte). evo: Element der meistgespielten Chips → Rookie.
const MONS := {
	"Pixmiez": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Katze",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Firewall", "Heilpatch", "Blitzcursor"],
		"passive": "Katzenreflex", "passive_desc": "Weicht dem ersten Treffer jedes Kampfes aus (ab Champion: den ersten zwei).",
		"trait": "Allrounder. Guter Einstieg.",
		"evo": {"Feuer": "Blazebit", "Code": "Firewallo", "Virus": "Virulina"}, "secret": "Prismiez",
	},
	"Funkling": {
		"hp": 80, "move": 0.12, "rech": 1.1, "el": "Feuer", "animal": "Welpe",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Glutball", "Glutball", "Flammenwelle", "Übertakten", "Firewall", "Byteschlag"],
		"passive": "Übermut", "passive_desc": "Jeder 3. gespielte Chip halbiert die Ladezeit der anderen Chips auf der Hand.",
		"trait": "Wenig HP, Chips laden 10 % schneller.",
		"evo": {"Feuer": "Glutbyte", "Code": "Overclocko"},
	},
	"Tröpfel": {
		"hp": 120, "move": 0.18, "rech": 1.0, "el": "Wasser", "animal": "Axolotl",
		"deck": ["Wasserstrahl", "Wasserstrahl", "Wasserstrahl", "Blubberschild", "Blubberschild", "Eisfeld", "Pixelstrahl", "Heilpatch"],
		"passive": "Regeneration", "passive_desc": "Heilt 1 HP pro Sekunde, wenn es 3 s nicht getroffen wurde (ab Champion: 2 HP).",
		"trait": "Viel HP, bewegt sich langsamer.",
		"evo": {"Wasser": "Kaskadi", "Code": "Pufferling"}, "ice": "Frostbyte",
	},
	# --- Weitere Linien aus dem Prototyp (Phase 3b, 29.09.2026), kommen aus Eiern ---
	"Kekso": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Hamster",
		"deck": ["Mini-Bot", "Mini-Bot", "Firewall", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Heilpatch", "Bug-Mine"],
		"passive": "Hamstern", "passive_desc": "25 % Chance: Ein gespielter Chip wird gehamstert und kommt gleich wieder.",
		"trait": "Ruft Helfer-Bots und legt Minen.",
		"evo": {"Virus": "Tracko", "Licht": "Cachy"},
	},
	"Lumi": {
		"hp": 85, "move": 0.1, "rech": 1.05, "el": "Licht", "animal": "Hase",
		"deck": ["Blitzcursor", "Blitzcursor", "Blitzcursor", "Heilpatch", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Firewall"],
		"passive": "Hasenhaken", "passive_desc": "Bewegt sich doppelt so schnell.",
		"trait": "Flink. Blitz-Angriffe treffen immer.",
		"evo": {"Licht": "Blinki", "Code": "Screenshina"},
	},
	"Quakli": {
		"hp": 95, "move": 0.12, "rech": 1.0, "el": "Virus", "animal": "Frosch",
		"deck": ["Virusspritzer", "Virusspritzer", "Virusspritzer", "Bug-Mine", "Bug-Mine", "Pixelstrahl", "Pixelstrahl", "Blubberschild"],
		"passive": "Giftbaut", "passive_desc": "Wer Quakli trifft, wird selbst vergiftet.",
		"trait": "Vergiftet Gegner und legt Minen.",
		"evo": {"Virus": "Virulurch", "Code": "Hüpfbyte"},
	},
	"Molchi": {
		"hp": 90, "move": 0.11, "rech": 1.0, "el": "Virus", "animal": "Salamander",
		"deck": ["Virusspritzer", "Virusspritzer", "Bug-Mine", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Glutball", "Heilpatch"],
		"passive": "Giftdrüsen", "passive_desc": "Gift und Brand auf dem Gegner wirken 50 % stärker.",
		"trait": "Flinker Gift-Salamander.",
		"evo": {"Virus": "Toxmolch", "Feuer": "Magmolch"},
	},
	"Brummbit": {
		"hp": 140, "move": 0.2, "rech": 1.05, "el": "Neutral", "animal": "Bär",
		"deck": ["Byteschlag", "Byteschlag", "Pixelstrahl", "Blitzcursor", "Heilpatch", "Heilpatch", "Firewall", "Blubberschild"],
		"passive": "Dickes Fell", "passive_desc": "Nimmt 25 % weniger Schaden.",
		"trait": "Tank. Viel HP, langsam, steckt viel weg.",
		"evo": {"Licht": "Sonnbrumm", "Code": "Bärtron"},
	},
	"Kauzbit": {
		"hp": 90, "move": 0.12, "rech": 1.0, "el": "Code", "animal": "Robo-Eule",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Mini-Bot", "Mini-Bot", "Firewall", "Blitzcursor", "Byteschlag", "Glutball"],
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
		"hp": 90, "move": 0.12, "rech": 1.1, "el": "Licht", "animal": "Hase × Hamster", "fusion": true,
		"deck": ["Blitzcursor", "Blitzcursor", "Mini-Bot", "Mini-Bot", "Defrag", "Heilpatch", "Firewall", "Pixelstrahl"],
		"passive": "Urwissen", "passive_desc": "Chips laden 10 % schneller, Defrag liegt schon im Deck.",
		"trait": "Fusion aus Licht und Erinnerung.", "evo": {},
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
	{"a": "Lumi", "b": "Kekso", "r": "Glyphel", "hint": "Licht und Erinnerung schreiben uralten Code."},
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
	"Prismiez": {"spr": "Prismiez_64", "stage": 2, "el": "Licht", "up": "Prismalynx"},
	"Glutbyte": {"spr": "Glutbyte_64", "stage": 2, "el": "Feuer", "up": "Magmawulf"},
	"Overclocko": {"spr": "Overclocko_64", "stage": 2, "el": "Code", "up": "Turbowulf"},
	"Kaskadi": {"spr": "Kaskadi_64", "stage": 2, "el": "Wasser", "up": "Tsunamander"},
	"Pufferling": {"spr": "Pufferling_64", "stage": 2, "el": "Code", "up": "Panzerpuff"},
	"Frostbyte": {"spr": "Frostbyte_64", "stage": 2, "el": "Wasser", "up": "Glaziolotl"},
	"Glutluchs": {"spr": "Glutluchs_80", "stage": 3, "el": "Feuer", "up": ""},
	"Bollwerkatz": {"spr": "Bollwerkatz_80", "stage": 3, "el": "Code", "up": ""},
	"Magmawulf": {"spr": "Magmawulf_80", "stage": 3, "el": "Feuer", "up": ""},
	"Turbowulf": {"spr": "Turbowulf_80", "stage": 3, "el": "Code", "up": ""},
	"Tsunamander": {"spr": "Tsunamander_80", "stage": 3, "el": "Wasser", "up": ""},
	"Panzerpuff": {"spr": "Panzerpuff_80", "stage": 3, "el": "Code", "up": ""},
	"Kekso": {"spr": "Kekso_32", "stage": 1, "el": "Neutral", "up": ""},
	"Tracko": {"spr": "Tracko_64", "stage": 2, "el": "Virus", "up": "Schattnager"},
	"Cachy": {"spr": "Cachy_64", "stage": 2, "el": "Licht", "up": "Glanzbacke"},
	"Lumi": {"spr": "Lumi_32", "stage": 1, "el": "Licht", "up": ""},
	"Blinki": {"spr": "Blinki_64", "stage": 2, "el": "Licht", "up": "Strahlhase"},
	"Screenshina": {"spr": "Screenshina_64", "stage": 2, "el": "Code", "up": "Holohas"},
	"Holohas": {"spr": "Holohas_80", "stage": 3, "el": "Code", "up": ""},
	"Quakli": {"spr": "Quakli_32", "stage": 1, "el": "Virus", "up": ""},
	"Virulurch": {"spr": "Virulurch_64", "stage": 2, "el": "Virus", "up": "Toxikröt"},
	"Hüpfbyte": {"spr": "Huepfbyte_64", "stage": 2, "el": "Code", "up": "Mechaquak"},
	"Mechaquak": {"spr": "Mechaquak_80", "stage": 3, "el": "Code", "up": ""},
	"Molchi": {"spr": "Molchi_32", "stage": 1, "el": "Virus", "up": ""},
	"Toxmolch": {"spr": "Toxmolch_64", "stage": 2, "el": "Virus", "up": "Sumpfdrak"},
	"Magmolch": {"spr": "Magmolch_64", "stage": 2, "el": "Feuer", "up": "Lavadrak"},
	"Brummbit": {"spr": "Brummbit_32", "stage": 1, "el": "Neutral", "up": ""},
	"Sonnbrumm": {"spr": "Sonnbrumm_64", "stage": 2, "el": "Licht", "up": "Sonnenpranke"},
	"Bärtron": {"spr": "Baertron_64", "stage": 2, "el": "Code", "up": "Titanbrumm"},
	"Titanbrumm": {"spr": "Titanbrumm_80", "stage": 3, "el": "Code", "up": ""},
	"Kauzbit": {"spr": "Kauzbit_32", "stage": 1, "el": "Code", "up": ""},
	"Optikauz": {"spr": "Optikauz_64", "stage": 2, "el": "Code", "up": "Radarkauz"},
	"Raketauz": {"spr": "Raketauz_64", "stage": 2, "el": "Feuer", "up": "Phönixkauz"},
	"Radarkauz": {"spr": "Radarkauz_80", "stage": 3, "el": "Code", "up": ""},
	"Dampfbyte": {"spr": "Dampfbyte_80", "stage": 3, "el": "Feuer", "up": ""},
	"Wolkerich": {"spr": "Wolkerich_80", "stage": 3, "el": "Wasser", "up": ""},
	"Glyphel": {"spr": "Glyphel_80", "stage": 3, "el": "Licht", "up": ""},
	"Spukatz": {"spr": "Spukatz_80", "stage": 3, "el": "Virus", "up": ""},
	# --- Champions (PixelLab, 29.09.2026) ---
	"Toxipanth": {"spr": "Toxipanth_80", "stage": 3, "el": "Virus", "up": ""},
	"Prismalynx": {"spr": "Prismalynx_80", "stage": 3, "el": "Licht", "up": ""},
	"Glaziolotl": {"spr": "Glaziolotl_80", "stage": 3, "el": "Wasser", "up": ""},
	"Schattnager": {"spr": "Schattnager_80", "stage": 3, "el": "Virus", "up": ""},
	"Glanzbacke": {"spr": "Glanzbacke_80", "stage": 3, "el": "Licht", "up": ""},
	"Strahlhase": {"spr": "Strahlhase_80", "stage": 3, "el": "Licht", "up": ""},
	"Toxikröt": {"spr": "Toxikroet_80", "stage": 3, "el": "Virus", "up": ""},
	"Sumpfdrak": {"spr": "Sumpfdrak_80", "stage": 3, "el": "Virus", "up": ""},
	"Lavadrak": {"spr": "Lavadrak_80", "stage": 3, "el": "Feuer", "up": ""},
	"Sonnenpranke": {"spr": "Sonnenpranke_80", "stage": 3, "el": "Licht", "up": ""},
	"Phönixkauz": {"spr": "Phoenixkauz_80", "stage": 3, "el": "Feuer", "up": ""},
}

const STAGE_NAMES := ["", "Baby", "Rookie", "Champion", "Ultra"]

## Prägung (gespielte Chips im Run), ab der die nächste Stufe erreicht wird
## Lebenszeit-Prägung (gespielte Chips über alle Runs): Rookie meist im ersten Run, Champion im zweiten/dritten
const EVO_AT := {2: 15, 3: 60}

## Signatur-Attacken je Form. Treffer (hits) landen im Abstand von 0,15 s und treffen immer.
## anim: jump (Sprung zum Gegner), row (Welle über die Gegnerreihe), field (ganzes Gegnerfeld), self (auf sich selbst)
const SPECIALS := {
	"Pixmiez": {"name": "Pixelsprung", "el": "Neutral", "anim": "jump", "hits": [40], "desc": "Springt zum Gegner und kratzt: 40 Schaden."},
	"Blazebit": {"name": "Flammensprung", "el": "Feuer", "anim": "jump", "hits": [45], "burn": 4, "desc": "Brennender Sprung: 45 Schaden + Brand."},
	"Glutluchs": {"name": "Glutkrallen", "el": "Feuer", "anim": "jump", "hits": [30, 30], "burn": 6, "desc": "Zwei Flammenhiebe à 30 + langer Brand."},
	"Firewallo": {"name": "Schildsprung", "el": "Code", "anim": "jump", "hits": [35], "shield": 4.0, "desc": "35 Schaden, landet mit Firewall-Schild (4 s)."},
	"Bollwerkatz": {"name": "Bollwerksprung", "el": "Code", "anim": "jump", "hits": [50], "stun": 1.0, "shield": 6.0, "desc": "Mecha-Sprung: 50 Schaden, betäubt 1 s, Firewall-Schild (6 s)."},
	"Virulina": {"name": "Giftkralle", "el": "Virus", "anim": "jump", "hits": [35], "poison": 6, "desc": "35 Schaden + starkes Gift."},
	"Prismiez": {"name": "Prismasprung", "el": "Licht", "anim": "jump", "hits": [40], "heal": 20, "desc": "40 Schaden und heilt 20 HP."},
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
	"Kekso": {"name": "Backentasche", "el": "Neutral", "anim": "self", "hits": [], "replay": true, "desc": "Spuckt den zuletzt gespielten Chip gratis noch einmal aus (sonst 30 Schaden)."},
	"Tracko": {"name": "Keksfalle", "el": "Virus", "anim": "self", "hits": [], "replay": true, "mines": 2, "desc": "Backentasche und zwei Virus-Minen um den Gegner."},
	"Cachy": {"name": "Leuchtkeks", "el": "Licht", "anim": "self", "hits": [], "replay": true, "heal": 30, "desc": "Backentasche und heilt 30 HP."},
	"Lumi": {"name": "Cursorblitz", "el": "Licht", "anim": "field", "hits": [35], "desc": "Blitz, der immer trifft: 35 Schaden."},
	"Blinki": {"name": "Dreifachblitz", "el": "Licht", "anim": "field", "hits": [22, 22, 22], "desc": "Drei Blitze à 22."},
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
	"Sonnbrumm": {"name": "Sonnenumarmung", "el": "Licht", "anim": "self", "hits": [30], "heal": 35, "desc": "Heilt 35 HP und trifft mit 30 Schaden."},
	"Bärtron": {"name": "Raketenfaust", "el": "Code", "anim": "row", "hits": [60], "stun": 1.0, "desc": "Mechanische Faust: 60 Schaden, betäubt 1 s."},
	"Titanbrumm": {"name": "Doppelraketenfaust", "el": "Code", "anim": "row", "hits": [45, 45], "stun": 1.5, "desc": "Zwei Raketenfäuste à 45, betäubt 1,5 s."},
	"Kauzbit": {"name": "Scanblick", "el": "Code", "anim": "self", "hits": [15], "scan": 3, "desc": "15 Schaden, deine nächsten 3 Treffer machen +50 %."},
	"Optikauz": {"name": "Laserblick", "el": "Code", "anim": "row", "hits": [50], "desc": "Laser aus den Linsenaugen: 50 Schaden."},
	"Raketauz": {"name": "Düsenangriff", "el": "Feuer", "anim": "field", "hits": [20, 20, 20], "burn": 4, "desc": "Drei Zielraketen à 20 + Brand."},
	"Radarkauz": {"name": "Zielerfassung", "el": "Code", "anim": "self", "hits": [30], "scan": 5, "desc": "30 Schaden, deine nächsten 5 Treffer machen +50 %."},
	"Dampfbyte": {"name": "Dampfexplosion", "el": "Wasser", "anim": "field", "hits": [30], "burn": 3, "stun": 1.0, "desc": "Heißer Dampf übers ganze Gegnerfeld: 30 + Brand, betäubt 1 s."},
	"Wolkerich": {"name": "Datenwolke", "el": "Wasser", "anim": "field", "hits": [15], "bubble": 60, "bubble_t": 6.0, "heal": 20, "desc": "Schutzblase (60, 6 s), heilt 20 HP und trifft das ganze Feld mit 15."},
	"Glyphel": {"name": "Urcode", "el": "Licht", "anim": "self", "hits": [25], "recharge": true, "scan": 3, "desc": "Lädt alle Chips, 25 Schaden, die nächsten 3 Treffer +50 %."},
	"Toxipanth": {"name": "Giftsprung", "el": "Virus", "anim": "jump", "hits": [50], "poison": 8, "desc": "Lautloser Sprung: 50 Schaden + starkes Gift."},
	"Prismalynx": {"name": "Prismastrahl", "el": "Licht", "anim": "field", "hits": [45], "heal": 30, "desc": "Regenbogenlicht übers ganze Feld: 45 Schaden, heilt 30 HP."},
	"Glaziolotl": {"name": "Gletscherwelle", "el": "Wasser", "anim": "field", "hits": [45], "stun": 3.0, "desc": "Eisige Flut übers ganze Feld: 45 Schaden, friert 3 s ein."},
	"Schattnager": {"name": "Schattenfalle", "el": "Virus", "anim": "self", "hits": [20], "replay": true, "mines": 3, "desc": "Backentasche, drei Virus-Minen und 20 Schaden."},
	"Glanzbacke": {"name": "Sonnenkeks", "el": "Licht", "anim": "self", "hits": [20], "replay": true, "heal": 45, "desc": "Backentasche, heilt 45 HP und trifft mit 20."},
	"Strahlhase": {"name": "Lichtgewitter", "el": "Licht", "anim": "field", "hits": [20, 20, 20, 20], "desc": "Vier Lichtblitze à 20."},
	"Toxikröt": {"name": "Seuchenwolke", "el": "Virus", "anim": "field", "hits": [30], "poison": 12, "desc": "Giftwolke übers ganze Feld: 30 + sehr langes Gift."},
	"Sumpfdrak": {"name": "Sumpfatem", "el": "Virus", "anim": "row", "hits": [45], "poison": 8, "desc": "Giftiger Atem über die Gegnerreihe: 45 + Gift."},
	"Lavadrak": {"name": "Lavaflut", "el": "Feuer", "anim": "field", "hits": [40], "burn": 6, "desc": "Lava übers ganze Gegnerfeld: 40 + langer Brand."},
	"Sonnenpranke": {"name": "Sonnenschlag", "el": "Licht", "anim": "jump", "hits": [55], "heal": 40, "desc": "Leuchtender Prankenhieb: 55 Schaden, heilt 40 HP."},
	"Phönixkauz": {"name": "Phönixsturz", "el": "Feuer", "anim": "jump", "hits": [60], "burn": 6, "desc": "Flammender Sturzflug: 60 Schaden + Brand."},
	"Spukatz": {"name": "Spukschlag", "el": "Virus", "anim": "jump", "hits": [45], "poison": 6, "decoy": 1, "decoy_t": 6.0, "desc": "Geisterhafter Sprung: 45 + Gift, ein Abbild fängt den nächsten Treffer ab."},
}

const BEATS := {"Feuer": "Code", "Code": "Wasser", "Wasser": "Feuer"}
const RARITY_WEIGHT := {"Gewöhnlich": 6, "Selten": 3, "Episch": 1}


static func mult(a: String, d: String) -> float:
	if BEATS.get(a, "") == d:
		return 1.5
	if BEATS.get(d, "") == a:
		return 0.75
	if (a == "Licht" and d == "Virus") or (a == "Virus" and d == "Licht"):
		return 1.5
	return 1.0
