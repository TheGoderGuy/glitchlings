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
}

const FOES := [
	{"name": "Bugsy", "el": "Virus", "hp": 70, "move": 1.4, "atk": 2.4, "dmg": 10, "pat": ["row"], "spr": "bug", "loot": 10, "boss": false, "tele": false},
	{"name": "Glitchmotte", "el": "Licht", "hp": 60, "move": 1.0, "atk": 2.0, "dmg": 14, "pat": ["cell"], "spr": "moth", "loot": 10, "boss": false, "tele": true},
	{"name": "Spamlet", "el": "Virus", "hp": 90, "move": 1.6, "atk": 2.6, "dmg": 12, "pat": ["row", "col"], "spr": "spam", "loot": 10, "boss": false, "tele": false},
	{"name": "Pop-Up-Tyrann", "el": "Virus", "hp": 320, "move": 1.8, "atk": 2.2, "dmg": 16, "pat": ["row"], "spr": "boss", "loot": 30, "boss": true, "tele": false},
]

const MONS := {
	"Pixmiez": {
		"hp": 100, "move": 0.12, "rech": 1.0, "spr": "pixi", "el": "Neutral", "stage": "Baby",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Firewall", "Heilpatch", "Blitzcursor"],
		"passive": "Katzenreflex", "passive_desc": "Weicht dem ersten Treffer jedes Kampfes aus.",
		"special": "Pixelsprung", "special_el": "Neutral", "special_desc": "Springt zum Gegner und kratzt: 40 Schaden, trifft immer.",
	},
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
