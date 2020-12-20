extends Node2D

var is_paused: bool = false

func _ready():
	fill_tilemaps()
	init_ui()
	$Timer.start()


func update_state():
	print("Updating to state: ", $HUD/Timeline.value)
	
	if $HUD/Timeline.value >= len(Global.gamelog["states"]):
		# Should never reach here if init_ui set max_value properly
		return
	
	var state = Global.gamelog["states"][$HUD/Timeline.value]
	
	# TODO: update state


func end_of_game():
	# TODO: display some end-of-game thing
	print("GAME OVER")
	get_tree().quit()


func init_ui():
	$HUD/Timeline.max_value = 5#len(Global.gamelog["states"])


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
	elif $HUD/Timeline.value == $HUD/Timeline.max_value:
		end_of_game()
	else:
		update_state()
		$HUD/Timeline.value += 1


func _on_PlayButton_pressed():
	is_paused = not is_paused
	if is_paused:
		$HUD/PlayButton.text = "Play"
	else:
		$HUD/PlayButton.text = "Pause"
