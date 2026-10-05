class_name LangENNames
extends RefCounted
## Englische Namen (01.10.2026): Glitchlinge, Gegner, Chips, Signaturen, Passive, Module, Zonen, Elemente.
## Neue Monsternamen wurden mit tools/namecheck gegen Pokémon (deutsch + englisch) und Digimon geprüft.
## Bugsy und Blinki behalten ihren Namen (wie im Deutschen). Vor dem Launch: echte Markenprüfung.

const D := {
	# ---------- Elemente, Seltenheit, Chip-Arten, Stufen ----------
	"Feuer": "Fire", "Wasser": "Water", "Code": "Code", "Elektro": "Electric", "Virus": "Virus", "Neutral": "Neutral",
	"Gewöhnlich": "Common", "Selten": "Rare", "Episch": "Epic", "Legendär": "Legendary",
	"Angriff": "Attack", "Schild": "Shield", "Falle": "Trap", "Buff": "Buff", "Feldeffekt": "Field", "Beschwörung": "Summon",
	"Baby": "Baby", "Rookie": "Rookie", "Champion": "Champion", "Ultra": "Ultra",

	# ---------- Tiere ----------
	"Katze": "Cat", "Welpe": "Puppy", "Axolotl": "Axolotl", "Hamster": "Hamster", "Hase": "Hare", "Frosch": "Frog",
	"Salamander": "Salamander", "Bär": "Bear", "Robo-Eule": "Robo-owl", "Dachs": "Badger", "Waschbär": "Raccoon", "Otter": "Otter", "Ara": "Macaw",
	"Axolotl × Hamster": "Axolotl × Hamster", "Hase × Eule": "Hare × Owl", "Bär × Hamster": "Bear × Hamster",
	"Hamster × Frosch": "Hamster × Frog", "Katze × Frosch": "Cat × Frog",

	# ---------- Glitchlinge ----------
	# Katze
	"Pixmiez": "Pixmeow", "Firewallo": "Firewallo", "Virulina": "Virulina", "Prismiez": "Prismeow",
	"Bollwerkatz": "Bulwarkat", "Toxipanth": "Toxipanth", "Prismalynx": "Prismalynx",
	"Bastionkatz": "Bastionkat", "Venomynx": "Venomynx", "Aurorlynx": "Aurorlynx",
	# Welpe
	"Funkling": "Sparkpup", "Glutbyte": "Emberbyte", "Overclocko": "Overclocko",
	"Magmawulf": "Magmawolf", "Turbowulf": "Turbowolf", "Glutfenrir": "Blazefenrir", "Hyperwulf": "Hyperwolf",
	# Axolotl
	"Tröpfel": "Droplotl", "Kaskadi": "Kaskadi", "Pufferling": "Pufferling", "Frostbyte": "Frostbyte",
	"Tsunamander": "Tsunamander", "Panzerpuff": "Armorpuff", "Glaziolotl": "Glaziolotl",
	"Leviamander": "Leviamander", "Kolosspuff": "Colossopuff", "Kryolotl": "Kryolotl",
	# Hamster
	"Kekso": "Crumbster", "Tracko": "Tracko", "Cachy": "Cachy", "Schattnager": "Shadowgnaw", "Glanzbacke": "Shinecheek",
	"Phantomnager": "Phantomgnaw", "Stellarbacke": "Stellarcheek",
	# Hase
	"Lumi": "Lumi", "Blinki": "Blinki", "Perlhopp": "Pearlhop", "Strahlhase": "Beamhare", "Gischthase": "Sprayhare",
	"Plasmahase": "Plasmahare", "Lunaflut": "Lunatide",
	# Frosch
	"Quakli": "Croakle", "Virulurch": "Virulurk", "Hüpfbyte": "Hopbyte", "Toxikröt": "Toxitoad", "Mechaquak": "Mechacroak",
	"Miasmakröt": "Miasmatoad", "Gigaquak": "Gigacroak",
	# Salamander
	"Molchi": "Newtie", "Toxmolch": "Toxnewt", "Magmolch": "Magmanewt", "Sumpfdrak": "Swampdrake", "Lavadrak": "Lavadrake",
	"Hydradrak": "Hydradrake", "Vulkandrak": "Volcanodrake",
	# Bär
	"Brummbit": "Rumblebit", "Bärtron": "Ursotron", "Pilzbrumm": "Fungrumble", "Titanbrumm": "Titanrumble",
	"Sporenpranke": "Sporepaw", "Kolossbrumm": "Colossorumble", "Myzelgrizz": "Mycelgrizz",
	# Robo-Eule
	"Kauzbit": "Hootbit", "Optikauz": "Optihoot", "Raketauz": "Rockethoot", "Radarkauz": "Radarhoot", "Phönixkauz": "Phoenixhoot",
	"Orbitkauz": "Orbithoot", "Infernokauz": "Infernohoot",
	# Dachs
	"Buddli": "Burrli", "Glimmdachs": "Glowbadger", "Zackdachs": "Zapbadger", "Magmadachs": "Magmabadger",
	"Donnerdachs": "Thunderbadger", "Pyromeles": "Pyromeles", "Voltameles": "Voltameles",
	# Waschbär
	"Maskli": "Maskli", "Plätschbär": "Puddlecoon", "Klaubär": "Pilfercoon", "Flutmaske": "Floodmask", "Nachtmaske": "Nightmask",
	"Hydrocyon": "Hydrocyon", "Virocyon": "Virocyon",
	"Bachli": "Brookli", "Strudli": "Swirli", "Wogotter": "Tideotter", "Hydrolutra": "Hydrolutra",
	"Knisterli": "Crackli", "Lutrion": "Lutrion", "Fulgurlutra": "Fulgurlutra",
	"Plapperli": "Chatterli", "Surrfeder": "Buzzfeather", "Sturmschwinge": "Stormwing", "Fulgopsitta": "Fulgopsitta",
	"Glutfeder": "Emberfeather", "Flammschwinge": "Flamewing", "Heliopsitta": "Heliopsitta",
	# Fusionen
	"Wolkerich": "Cloudster", "Spukatz": "Spookat", "Wolperling": "Jackalowl", "Schlummerbit": "Slumberbit", "Pustebacke": "Puffcheek",

	# ---------- Gegner, Wächter, Bosse ----------
	"Bugsy": "Bugsy", "Glitchmotte": "Glitchmoth", "Bytewurm": "Byteworm", "Kernelmantis": "Kernelmantis",
	"Chiffrekäfer": "Cipherbeetle", "Datenwespe": "Datawasp", "Glutraupe": "Emberpillar", "Glutmilbe": "Embermite",
	"Brandmauerassel": "Firelouse", "Aschefalter": "Cinderwing", "Glutkernskarabäus": "Embercore Scarab",
	"Saugmücke": "Leechgnat", "Funkenkäfer": "Sparkbeetle", "Datenegel": "Dataleech", "Moorlibelle": "Mirefly", "Sentinelkrabbe": "Sentinelcrab", "Fehlerqualle": "Errorjelly", "Panzerschnecke": "Armorsnail", "Glitchblüte": "Glitchbloom", "Schwarmkönigin": "Swarm Queen",
	"Kerndrohne": "Core Drone", "Glitchspinne": "Glitchspider", "Ur-Glitch": "Ur-Glitch",
	"Sprungschreck": "Leapfright", "Dornwurz": "Thornroot", "Schlackwurm": "Slagworm", "Magmaskorp": "Magmascorp",
	"Schnappkelch": "Snapmaw", "Schlickkrake": "Siltkraken", "Skolopendrox": "Skolopendrox",
	"Elite-": "Elite ", "Glitch-": "Glitch ",
	# Großangriffe
	"Sensenkreuz": "Scythe Cross", "Klingenhatz": "Blade Hunt", "Sonnenrad": "Sun Wheel", "Kernschmelze": "Meltdown",
	"Schwarmwelle": "Swarm Wave", "Stachelregen": "Stinger Rain", "Systemabsturz": "System Crash", "Kernfehler": "Core Fault",
	"Totalausfall": "Total Failure", "Datenlöschung": "Data Wipe", "Hüpfjagd": "Hop Hunt", "Dornenteppich": "Thorn Carpet",
	"Magmageysir": "Magma Geyser", "Scherenzange": "Pincer Grip", "Fangschlund": "Snare Maw", "Tentakelwirbel": "Tentacle Whirl",
	"Segmentfeuer": "Segment Fire",

	# ---------- Zonen ----------
	"Cache-Wiesen": "Cache Meadows", "Firewall-Vulkan": "Firewall Volcano", "Viren-Sümpfe": "Virus Swamps", "NEST-Kern": "NEST Core",

	# ---------- Chips ----------
	"Pixelstrahl": "Pixel Beam", "Byteschlag": "Byte Strike", "Firewall": "Firewall", "Bug-Mine": "Bug Mine",
	"Übertakten": "Overclock", "Glutball": "Ember Ball", "Flammenwelle": "Flame Wave", "Wasserstrahl": "Water Jet",
	"Blubberschild": "Bubble Shield", "Eisfeld": "Ice Field", "Heilpatch": "Heal Patch", "Blitzcursor": "Flash Cursor",
	"Mini-Bot": "Mini-Bot", "Virusspritzer": "Virus Spray", "Defrag": "Defrag", "Doppelklick": "Double Click",
	"Neustart": "Reboot", "Funkenregen": "Spark Rain", "Hitzeschild": "Heat Shield", "Laserschuss": "Laser Shot",
	"Portscan": "Port Scan", "Strudel": "Whirlpool", "Nebel": "Mist", "Blitzlanze": "Bolt Lance",
	"Blendgranate": "Flashbang", "Wurmloch": "Wormhole", "Kurzschluss": "Short Circuit", "Datenfresser": "Data Eater",
	"Glutklinge": "Ember Blade", "Feuersbrunst": "Firestorm", "Flutwelle": "Tidal Wave", "Frostsplitter": "Frost Shard",
	"Tsunami": "Tsunami", "Kopierschutz": "Copy Guard", "Geschützturm": "Turret", "Debugger": "Debugger",
	"Kettenblitz": "Chain Bolt", "Ladungsfeld": "Charge Field", "Magnetfeld": "Magnet Field", "Blackout": "Blackout",
	"Seuche": "Plague", "Sporenfalle": "Spore Trap", "Parasit": "Parasite", "Sprungantrieb": "Jump Drive", "Konter": "Counter",

	# ---------- Passive ----------
	"Katzenreflex": "Cat Reflex", "Übermut": "Bravado", "Regeneration": "Regeneration", "Hamstern": "Hoarding",
	"Hasenhaken": "Hare Dash", "Giftbaut": "Toxic Skin", "Giftdrüsen": "Venom Glands", "Dickes Fell": "Thick Fur",
	"Eulenblick": "Owl Eyes", "Furchtlos": "Fearless", "Langfinger": "Sticky Fingers", "Teamgeist": "Team Spirit", "Nachplappern": "Parrot Talk", "Wolkendecke": "Cloud Cover",
	"Mischwesen": "Hybrid", "Winterschlaf": "Hibernation", "Schwebegas": "Float Gas", "Spuk": "Haunt",

	# ---------- Signatur-Attacken ----------
	"Pixelsprung": "Pixel Pounce", "Schildsprung": "Shield Pounce", "Bollwerksprung": "Bulwark Pounce", "Giftkralle": "Venom Claw",
	"Prismasprung": "Prism Pounce", "Funkenbiss": "Spark Bite", "Glutbiss": "Ember Bite", "Magmasturm": "Magma Storm",
	"Überladung": "Overload", "Turboschub": "Turbo Boost", "Blubberwelle": "Bubble Wave", "Kaskadenflut": "Cascade Flood",
	"Aufblähen": "Puff Up", "Panzerblase": "Armor Bubble", "Frostwelle": "Frost Wave", "Backentasche": "Cheek Pouch",
	"Keksfalle": "Cookie Trap", "Leuchtkeks": "Glow Cookie", "Cursorblitz": "Cursor Bolt", "Dreifachblitz": "Triple Bolt",
	"Zungenschlag": "Tongue Lash", "Giftwolke": "Toxic Cloud", "Datensprung": "Data Leap", "Kolbensprung": "Piston Leap",
	"Giftspucke": "Venom Spit", "Toxinregen": "Toxin Rain", "Lavastrom": "Lava Stream", "Tatzenhieb": "Paw Swipe",
	"Raketenfaust": "Rocket Fist", "Doppelraketenfaust": "Double Rocket Fist", "Scanblick": "Scan Gaze", "Laserblick": "Laser Gaze",
	"Düsenangriff": "Jet Strike", "Zielerfassung": "Target Lock", "Datenwolke": "Data Cloud", "Giftsprung": "Venom Pounce",
	"Prismastrahl": "Prism Ray", "Gletscherwelle": "Glacier Wave", "Schattenfalle": "Shadow Trap", "Sonnenkeks": "Sun Cookie",
	"Blitzgewitter": "Lightning Storm", "Seuchenwolke": "Plague Cloud", "Sumpfatem": "Swamp Breath", "Lavaflut": "Lava Flood",
	"Phönixsturz": "Phoenix Dive", "Bastionssprung": "Bastion Pounce", "Dreigiftschweif": "Triple Venom Tail",
	"Polarlicht": "Aurora", "Fenrirbrand": "Fenrir Blaze", "Hyperschub": "Hyper Boost", "Leviathanflut": "Leviathan Flood",
	"Kolossblase": "Colossal Bubble", "Absoluter Nullpunkt": "Absolute Zero", "Phantomfalle": "Phantom Trap",
	"Sternenkeks": "Star Cookie", "Plasmasturm": "Plasma Storm", "Miasma": "Miasma", "Gigasprung": "Giga Leap",
	"Dreikopfatem": "Three-Head Breath", "Eruption": "Eruption", "Kolossfäuste": "Colossal Fists", "Infernosturz": "Inferno Dive",
	"Orbitalschlag": "Orbital Strike", "Geweihblitz": "Antler Bolt", "Buddelstoß": "Burrow Strike", "Glutgrabung": "Ember Dig",
	"Magmaausbruch": "Magma Burst", "Erdkernbrecher": "Core Breaker", "Zackenstreif": "Zigzag Stripe", "Donnergrube": "Thunder Pit",
	"Hochspannungsgraben": "High-Voltage Trench", "Taschendieb": "Pickpocket", "Waschgang": "Wash Cycle", "Flutraubzug": "Flood Heist",
	"Sintflut-Coup": "Deluge Coup", "Giftgriff": "Venom Grab", "Schattenraub": "Shadow Heist", "Datenraubzug": "Data Heist",
	"Bauchrutscher": "Belly Slide", "Strudelwirbel": "Swirl Spin", "Wogenbrecher": "Wavebreaker", "Mahlstrom": "Maelstrom",
	"Schnurrhaarblitz": "Whisker Bolt", "Donnerwirbel": "Thunder Spin", "Gewitterfront": "Storm Front",
	"Plapperschwall": "Chatter Burst", "Surrsturz": "Buzz Dive", "Federsalve": "Feather Volley", "Donnerschrei": "Thunder Shriek",
	"Glutfedern": "Ember Feathers", "Feuerfächer": "Fire Fan", "Sonnensturz": "Sun Dive",
	"Schlaflied": "Lullaby", "Gasexplosion": "Gas Blast", "Sporenwolke": "Spore Cloud", "Giftpranke": "Venom Paw",
	"Myzelnetz": "Mycelium Web", "Perlenschuss": "Pearl Shot", "Gischtsprung": "Spray Leap", "Springflut": "Spring Tide",
	"Spukschlag": "Haunt Strike",

	# ---------- Module ----------
	"Verstärker": "Amplifier", "Schnelllader": "Quick Loader", "Startsignal": "Start Signal", "Panzerplatte": "Armor Plate",
	"Sammler": "Collector", "Lebensbit": "Life Bit", "Schleimschuhe": "Slime Boots", "Rabattchip": "Discount Chip",
	"Überhitzer": "Overheater", "Giftkapsel": "Venom Capsule", "Kältekern": "Cold Core", "Elementlinse": "Element Lens",
	"Dornenpanzer": "Thorn Armor", "Reflexbooster": "Reflex Booster", "Prisma": "Prism", "Kondensator": "Capacitor",
	"Notschild": "Emergency Shield", "Suchalgorithmus": "Search Algorithm", "Backup-Kern": "Backup Core", "Kritbit": "Critbit",
	"Saugbit": "Leechbit", "Echochip": "Echo Chip",

	# ---------- Station-Ausbau ----------
	"Werkbank": "Workbench", "Vorratslager": "Storehouse", "Modulschacht": "Module Bay", "Fragmentfilter": "Fragment Filter",
	"Brutwärmer": "Incubator", "Nest-Erweiterung": "Nest Expansion",
}
