extends Node2D

var is_paused: bool = false
var cam_bounds: Rect2

onready var timeline: Slider = $HUD/VBoxContainer/Controls/Timeline
onready var play_button: Button = $HUD/VBoxContainer/Controls/PlayButton

func _ready():
	update_state(0)
	init_ui()
	$Timer.start()


func _input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		$Timer.paused = true
	elif event.is_action_released("cam_drag"):
		$Timer.paused = false


func update_state(state_num: int):
	print("Updating to state: ", state_num)
	
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if init_ui set max_value properly
	
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"], state["players"])


func end_of_game():
	# TODO: display some end-of-game thing
	print("GAME OVER")
	timeline.value = timeline.min_value # Loop for debugging
	#get_tree().quit()


func init_ui():
	$Camera.tilemap_bounds = get_tilemap_bounds($Map/Base)
	timeline.max_value = len(Global.gamelog["states"]) - 1


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


func _on_Timer_timeout():
	if is_paused:
		return
	elif timeline.value >= timeline.max_value:
		end_of_game()
	else:
		timeline.value += 1


func _on_PlayButton_pressed():
	is_paused = not is_paused
	if is_paused:
		play_button.text = "Play"
	else:
		play_button.text = "Pause"


func get_tilemap_bounds(tilemap: TileMap) -> Rect2:
	var cell_bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D(Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)


func _on_Timeline_value_changed(value):
	update_state(value)
