extends Node2D

var is_paused: bool = false
var cam_bounds: Rect2


func _ready():
	fill_tilemaps()
	init_ui()
	update_state()
	$Timer.start()


func update_state():
	print("Updating to state: ", $HUD/Timeline.value)
	
	if $HUD/Timeline.value >= len(Global.gamelog["states"]):
		return # Should never reach here if init_ui set max_value properly
	
	var state = Global.gamelog["states"][$HUD/Timeline.value]
	# TODO: update state


func end_of_game():
	# TODO: display some end-of-game thing
	print("GAME OVER")
	#get_tree().quit()


func init_ui():
	$Camera.tilemap_bounds = get_tilemap_bounds($Map/Base)
	$HUD/Timeline.max_value = len(Global.gamelog["states"]) - 1


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


func _on_Timer_timeout():
	if is_paused:
		return
	elif $HUD/Timeline.value >= $HUD/Timeline.max_value:
		end_of_game()
	else:
		$HUD/Timeline.value += 1
		update_state()


func _on_PlayButton_pressed():
	is_paused = not is_paused
	if is_paused:
		$HUD/PlayButton.text = "Play"
	else:
		$HUD/PlayButton.text = "Pause"


func get_tilemap_bounds(tilemap: TileMap) -> Rect2:
	var cell_bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D(Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)
