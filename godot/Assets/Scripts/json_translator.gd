extends Node

func parse_json(filepath: String):
	var file = File.new()
	file.open(filepath, file.READ)
	var json_result = JSON.parse(file.get_as_text())
	if json_result.error != OK:
		return null
	file.close()
	return json_result.result


### Verification functions ###
func valid_gamelog(gamelog: Dictionary) -> bool:
	# Check that top-level dictionary keys are valid
	var gamelog_keys = ["states"]
	for key in gamelog_keys:
		if not gamelog.keys().has(key):
			return false
	
	for state in gamelog["states"]:
		if not valid_game_state(state):
			return false
	
	return true


func valid_tile_map(tile_map: Dictionary) -> bool:
	# Check that top-level dictionary keys are valid
	var keys = ["mapHeight", "mapWidth", "tiles"]
	for key in keys:
		if not tile_map.keys().has(key):
			return false
	
	if len(tile_map["tiles"]) != tile_map["mapHeight"]:
		return false
	
	for row in tile_map["tiles"]:
		if len(row) != tile_map["mapWidth"]:
			return false
		for tile in row:
			if not valid_tile(tile):
				return false
	
	return true


func valid_game_state(state: Dictionary) -> bool:
	var keys = ["players", "tileMap"]
	for key in keys:
		if not state.keys().has(key):
			return false
	
	if not valid_tile_map(state["tileMap"]):
		return false
	
	if len(state["players"]) != 2:
		return false
	for player in state["players"]:
		if not valid_player(player, state["tileMap"]):
			return false
	
	return true


func valid_player(player: Dictionary, tilemap: Dictionary) -> bool:
	var keys = ["name", "position", "item", "upgrade", "money"]
	for key in keys:
		if not player.keys().has(key):
			return false
	
	# JSON parsing will always interpret numbers as floats/reals
	if typeof(player["money"]) != TYPE_REAL or player["money"] < 0:
		return false
	
	if not valid_item(player["item"]) \
			or not valid_position(player["position"], tilemap) \
			or not valid_upgrade(player["upgrade"]):
		return false
	return true


func valid_position(pos: Dictionary, tilemap: Dictionary) -> bool:
	if not (pos.keys().has("x") and pos.keys().has("y")):
		return false
	if pos["x"] < 0 or pos["x"] >= tilemap["mapWidth"]:
		return false
	if pos["y"] < 0 or pos["y"] >= tilemap["mapHeight"]:
		return false
	
	return true


func valid_tile(tile: Dictionary) -> bool:
	var keys = ["type"]
	for key in keys:
		if not tile.keys().has(key):
			return false
	
	return true


func valid_item(item: Dictionary) -> bool:
	var keys = ["type"]
	for key in keys:
		if not item.keys().has(key):
			return false
	
	# TODO: Check that ItemType is in enum range
	
	return true


func valid_upgrade(upgrade: int) -> bool:
	# TODO: Check that upgrade is in enum range
	return true
