extends Node2D

var cam_bounds: Rect2

func _ready():
	update_state(0)


# Using _input because we want to pause the timer on ALL mouse down
# (e.g. when user is scrubbing through timeline)
var pause_cache: bool
func _input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		pause_cache = $GUI.get_paused()
		$GUI.set_paused(true)
	elif event.is_action_released("cam_drag"):
		$GUI.set_paused(pause_cache)


func update_state(state_num: int):
	print("Updating to state: ", state_num)
	
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if timeline max_value is set properly
	
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"], state["players"])


func fill_tilemaps(map: Dictionary, players: Array):
	var tileset = $Map/Base.tile_set
	
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			$Map/Base.set_cell(x, y, map["tiles"][y][x]["type"])
	
	# Applies auto-tiling rules
	$Map/Base.update_bitmask_region()
	
	# Fill in character layer
	var init_pos = [
		players[0]["position"],
		players[1]["position"]
	]
	var p1 = tileset.find_tile_by_name("Player 1")
	var p2 = tileset.find_tile_by_name("Player 2")
	$Map/Characters.set_cell(init_pos[0]["x"], init_pos[0]["y"], p1)
	$Map/Characters.set_cell(init_pos[1]["x"], init_pos[1]["y"], p2)


func _on_GUI_timeline_changed(value):
	update_state(value)


func _on_GUI_game_over():
	# TODO: display some end-of-game thing
	print("GAME OVER")
	$GUI.reset()
	#get_tree().quit()
