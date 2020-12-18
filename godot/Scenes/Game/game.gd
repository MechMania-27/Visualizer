extends Node2D


func _ready():
	fill_tilemaps()


func fill_tilemaps():
	var tileset = $Map/Base.tile_set
	
	# Fill in base layer
	var map = Global.gamelog["tileMap"]
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			$Map/Base.set_cell(x, y, map["tiles"][y][x]["type"])
	
	# Applies auto-tiling rules
	$Map/Base.update_bitmask_region()
	
	# Fill in character layer
	var init_pos = Global.gamelog["initPlayersPos"]
	var p1 = tileset.find_tile_by_name("Player 1")
	var p2 = tileset.find_tile_by_name("Player 2")
	$Map/Characters.set_cell(init_pos[0]["x"], init_pos[0]["y"], p1)
	$Map/Characters.set_cell(init_pos[1]["x"], init_pos[1]["y"], p2)
