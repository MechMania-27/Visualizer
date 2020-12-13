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
	var gamelog_keys = ["tileMap", "playerNames", "initPlayersPos", "states"]
	for key in gamelog_keys:
		if not gamelog.keys().has(key):
			return false
	
	# Check playerNames
	if len(gamelog["playerNames"]) != 2:
		return false
	if gamelog["playerNames"][0] == gamelog["playerNames"][1]:
		return false
	
	# Check tileMap
	if not valid_tile_map(gamelog["tileMap"]):
		return false
	
	# Check initPlaysPos
	if len(gamelog["initPlayersPos"]) != 2:
		return false
	for pos in gamelog["initPlayersPos"]:
		if not (pos.keys().has("x") and pos.keys().has("y")):
			return false
		if pos["x"] < 0 or pos["x"] >= gamelog["tileMap"]["mapWidth"]:
			return false
		if pos["y"] < 0 or pos["y"] >= gamelog["tileMap"]["mapHeight"]:
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


func valid_tile(tile: Dictionary) -> bool:
	var keys = ["type"]
	for key in keys:
		if not tile.keys().has(key):
			return false
	
	return true


func valid_game_state(state: Dictionary) -> bool:
	var keys = ["playersPos", "tileMap"]
	for key in keys:
		if not state.keys().has(key):
			return false
	
	return valid_tile_map(state["tileMap"])
