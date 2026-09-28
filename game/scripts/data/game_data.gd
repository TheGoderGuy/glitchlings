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
}

## Alle Formen: Sprite-Datei, Stufe (1 Baby, 2 Rookie, 3 Champion), Element, nächste Stufe
const FORMS := {
	"Pixmiez": {"spr": "pixi_32", "stage": 1, "el": "Neutral", "up": ""},
	"Funkling": {"spr": "funk_32", "stage": 1, "el": "Feuer", "up": ""},
	"Tröpfel": {"spr": "drop_32", "stage": 1, "el": "Wasser", "up": ""},
	"Blazebit": {"spr": "Blazebit_64", "stage": 2, "el": "Feuer", "up": "Glutluchs"},
	"Firewallo": {"spr": "Firewallo_64", "stage": 2, "el": "Code", "up": "Bollwerkatz"},
	"Virulina": {"spr": "Virulina_64", "stage": 2, "el": "Virus", "up": ""},
	"Prismiez": {"spr": "Prismiez_64", "stage": 2, "el": "Licht", "up": ""},
	"Glutbyte": {"spr": "Glutbyte_64", "stage": 2, "el": "Feuer", "up": "Magmawulf"},
	"Overclocko": {"spr": "Overclocko_64", "stage": 2, "el": "Code", "up": "Turbowulf"},
	"Kaskadi": {"spr": "Kaskadi_64", "stage": 2, "el": "Wasser", "up": "Tsunamander"},
	"Pufferling": {"spr": "Pufferling_64", "stage": 2, "el": "Code", "up": "Panzerpuff"},
	"Frostbyte": {"spr": "Frostbyte_64", "stage": 2, "el": "Wasser", "up": ""},
	"Glutluchs": {"spr": "Glutluchs_80", "stage": 3, "el": "Feuer", "up": ""},
	"Bollwerkatz": {"spr": "Bollwerkatz_80", "stage": 3, "el": "Code", "up": ""},
	"Magmawulf": {"spr": "Magmawulf_80", "stage": 3, "el": "Feuer", "up": ""},
	"Turbowulf": {"spr": "Turbowulf_80", "stage": 3, "el": "Code", "up": ""},
	"Tsunamander": {"spr": "Tsunamander_80", "stage": 3, "el": "Wasser", "up": ""},
	"Panzerpuff": {"spr": "Panzerpuff_80", "stage": 3, "el": "Code", "up": ""},
}

const STAGE_NAMES := ["", "Baby", "Rookie", "Champion", "Ultra"]

## Prägung (gespielte Chips im Run), ab der die nächste Stufe erreicht wird
const EVO_AT := {2: 15, 3: 35}

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
