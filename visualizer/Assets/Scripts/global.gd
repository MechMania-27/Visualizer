# Auto-loaded script for global variables and communication specification
extends Node

# gamelog used to udpate visualization
var gamelog: Dictionary
var current_turn: int

### Enum Types ###

enum PlayerEndState {
	WON,
	LOST,
	TIED,
	ERROR,
}

# Values correspond to TileSet index
enum TileType {
	GREEN_GROCER = 5,
	GRASS = 4,
	ARID = 3,
	SOIL = 3,
	F_BAND_OUTER = 2,
	F_BAND_MID = 1,
	F_BAND_INNER = 0,
}

# Values correspond to TileSet index
enum CropType {
	NONE = -1,
	CORN,
	GRAPE,
	POTATO
}

enum Item {
	NONE,
}

enum Upgrade {
	NONE,
}

func _ready():
	set_process(false)

### Verification functions ###

var gamelog_states: Array
var progress_increment: float
var progress_text: String setget set_progress_text
var current_progress: float setget set_current_progress
signal progress_changed
signal progress_text_changed
signal verify_gamelog_start
signal gamelog_check_completed
signal gamelog_check_failed

# Changes recorded progression of verification
func set_current_progress(new: float):
	current_progress = new
	emit_signal("progress_changed", new)


# Changes text explaining current step in verifictation
func set_progress_text(new: String):
	progress_text = new
	emit_signal("progress_text_changed", new)


# Checks a game state every frame
func _process(_delta):
	#var t = OS.get_ticks_msec()
	
	# Each iteration take 9-13 msec
	for _i in range(3):
		if gamelog_states.empty():
			emit_signal("gamelog_check_completed")
			set_progress_text("Verification complete")
			set_process(false)
			return
		
		var state = gamelog_states.pop_front()
		if not valid_game_state(state):
			emit_signal("gamelog_check_failed")
			set_progress_text("Invalid gamelog")
			set_process(false)
			return
		
		set_current_progress(current_progress + progress_increment)
	#print(OS.get_ticks_msec() - t)


func valid_gamelog(_gamelog: Dictionary):
	#emit_signal("verify_gamelog_start")
	
	if not valid_keys(_gamelog) or not valid_end_states(_gamelog):
		emit_signal("gamelog_check_failed")
		return
	
	gamelog = _gamelog
	gamelog_states = gamelog["states"].duplicate(false)
	set_progress_text("Verifying game log...")
	progress_increment = 1.0 / gamelog_states.size()
	
	set_process(true)
	


func valid_keys(_gamelog: Dictionary) -> bool:
	set_progress_text("Verifying Keys...")
	
	var gamelog_keys = ["states", "p1_status", "p2_status"]
	for key in gamelog_keys:
		if not _gamelog.keys().has(key):
			printerr("Gamelog doesn't contain key: ", key)
			set_progress_text("File Error: Invalid keys")
			return false
	return true


func valid_end_states(_gamelog: Dictionary) -> bool:
	set_progress_text("Verifying Player End States...")
	
	if PlayerEndState.get(_gamelog["p1_status"]) == null:
		printerr("Invalid PlayerEndState for p1")
		set_progress_text("File Error: Invalid PlayerEndState for p1")
		return false
	
	if PlayerEndState.get(_gamelog["p2_status"]) == null:
		printerr("Invalid PlayerEndState for p2")
		set_progress_text("File Error: Invalid PlayerEndState for p2")
		return false
	
	return true


func valid_game_state(state: Dictionary) -> bool:
	var keys = ["p1", "p2", "tileMap"]
	for key in keys:
		if not state.keys().has(key):
			printerr("GameState did not contain key: ", key)
			return false
	
	if not valid_tile_map(state["tileMap"]):
		return false
	
	if not valid_player(state["p1"], state["tileMap"]):
		return false
	
	if not valid_player(state["p2"], state["tileMap"]):
		return false
	
	return true


func valid_tile_map(tile_map: Dictionary) -> bool:
	var keys = ["mapHeight", "mapWidth", "tiles"]
	for key in keys:
		if not tile_map.keys().has(key):
			printerr("TileMap did not contain key: ", key)
			return false
	
	if len(tile_map["tiles"]) != tile_map["mapHeight"]:
		printerr("TileMap had incorrect number of rows")
		return false
	
	for row in tile_map["tiles"]:
		if len(row) != tile_map["mapWidth"]:
			print("TileMap had incorrect number of columns")
			return false
		for tile in row:
			if not valid_tile(tile):
				return false
	
	return true


func valid_tile(tile: Dictionary) -> bool:
	var keys = ["type", "crop", "p1_item", "p2_item"]
	for key in keys:
		if not tile.keys().has(key):
			printerr("Tile did not have key: ", key)
			return false
	
	if TileType.get(tile["type"]) == null:
		printerr("Invalid TileType: ", tile["type"])
		return false
	
	if not valid_crop(tile["crop"]):
		return false
	
	if Item.get(tile["p1_item"]) == null:
		printerr("Invalid p1_item: ", tile["p1_item"])
		return false
	
	if Item.get(tile["p2_item"]) == null:
		printerr("Invalid p2_item: ", tile["p2_item"])
		return false
	
	return true


func valid_crop(crop: Dictionary) -> bool:
	var keys = ["type", "growthTimer"]
	for key in keys:
		if not crop.keys().has(key):
			printerr("Crop did not contain key: ", key)
			return false
	
	if CropType.get(crop["type"]) == null:
		printerr("Invalid crop type: ", crop["type"])
		return false
	
	# JSON parsing will always interpret numbers as floats/reals
	if CropType.get(crop["type"]) != CropType.NONE and \
			(typeof(crop["growthTimer"]) != TYPE_REAL \
			or int(crop["growthTimer"]) != crop["growthTimer"]):
		printerr("Invalid growthTimer: ", crop["growthTimer"])
		return false
	
	return true


func valid_player(player: Dictionary, tilemap: Dictionary) -> bool:
	var keys = ["name", "position", "item", "upgrade", "money", 
				"seedInventory", "harvestedInventory"]
	for key in keys:
		if not player.keys().has(key):
			printerr("Player missing key: ", key)
			return false
	
	if typeof(player["money"]) != TYPE_REAL:
		printerr("Player money must be a number")
		return false
	
	if Item.get(player["item"]) == null:
		printerr("Invalid player item: ", player["item"])
		return false
	
	if not valid_position(player["position"], tilemap):
		return false
	
	if Upgrade.get(player["upgrade"]) == null:
		printerr("Invalid player upgrade: ", player["upgrade"])
		return false
	
	# Validate seed inventory
	# Because of pass-by-reference, we can add some aggregate data here
	player["harvestedInventoryTotals"] = Dictionary()
	for key in CropType.keys():
		player["harvestedInventoryTotals"][key] = 0
		if not player["seedInventory"].keys().has(key):
			printerr("Player seedInventory missing key: %s" % key)
	
	# Validate harversted inventory and collect aggregates
	for crop in player["harvestedInventory"]:
		if not valid_crop(crop):
			printerr("Invalid crop in player harvestedInventory: %s" % crop)
			return false
		
		player["harvestedInventoryTotals"][crop["type"]] += 1 
	
	return true


func valid_position(pos: Dictionary, tilemap: Dictionary) -> bool:
	if not (pos.keys().has("x") and pos.keys().has("y")):
		printerr("Invalid position keys")
		return false
	if pos["x"] < 0 or pos["x"] >= tilemap["mapWidth"]:
		printerr("Position x out of bounds: ", pos["x"])
		return false
	if pos["y"] < 0 or pos["y"] >= tilemap["mapHeight"]:
		printerr("Position y out of bounds: ", pos["y"])
		return false
	
	return true
