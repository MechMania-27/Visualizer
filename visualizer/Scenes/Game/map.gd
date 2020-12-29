extends Node2D

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
	fill_tilemaps(state["tileMap"], state["players"])


func fill_tilemaps(map: Dictionary, players: Array):
	var tileset = $Base.tile_set
	
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			$Base.set_cell(x, y, map["tiles"][y][x]["type"])
	
	# Applies auto-tiling rules
	$Base.update_bitmask_region()
	
	# Fill in character layer
	var init_pos = [
		players[0]["position"],
		players[1]["position"]
	]
	var p1 = tileset.find_tile_by_name("Player 1")
	var p2 = tileset.find_tile_by_name("Player 2")
	$Characters.set_cell(init_pos[0]["x"], init_pos[0]["y"], p1)
	$Characters.set_cell(init_pos[1]["x"], init_pos[1]["y"], p2)
