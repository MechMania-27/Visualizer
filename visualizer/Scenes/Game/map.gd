extends Node2D

enum TileType {
	SOIL = 0,
	GREEN_GROCER = 1
}

# Maps from crop growth stage to atlas sprite coordinate
func get_crop(stage: int) -> Vector2:
	return Vector2(stage, 0)


func get_bounds() -> Rect2:
	var tilemap = $Base
	var bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D( \
			Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), \
			Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2() \
			)
	return Rect2(cell_to_pixel * bounds.position, cell_to_pixel * bounds.size)


func update_state(state_num: int):
	print("Updating to state: ", state_num)
	
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if timeline max_value is set properly
	
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"])
	update_players(state["players"])


func update_players(players: Array):
	var pos = Vector2(players[0]["position"]["x"], players[0]["position"]["y"])
	$Player1.global_transform.origin = $Base.map_to_world(pos)
	
	pos = Vector2(players[1]["position"]["x"], players[1]["position"]["y"])
	$Player2.global_transform.origin = $Base.map_to_world(pos)


func fill_tilemaps(map: Dictionary):
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			var tile: Dictionary = map["tiles"][y][x]
			match int(tile["type"]):
				TileType.SOIL:
					$Base.set_cell(x, y, tile["soilQuality"])
				TileType.GREEN_GROCER:
					$Base.set_cell(x, y, \
							$Base.tile_set.find_tile_by_name("Green Grocer"))
			
			# TODO: require a crop field
			if tile.keys().has("crop"):
				$Crops.set_cell(x, y, tile["crop"]["type"], false, false, \
						false, get_crop(tile["crop"]["growthTimer"]))
	
	# Applies auto-tiling rules
	$Base.update_bitmask_region()
