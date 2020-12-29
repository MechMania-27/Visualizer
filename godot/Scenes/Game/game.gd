extends Node2D

var cam_bounds: Rect2

onready var base_map = $Map/Base
onready var GUI = $GUI
onready var player_sprites = [$Map/Player1, $Map/Player2]
onready var player_tweens = [$Map/Player1/Tween, $Map/Player2/Tween]

func _ready():
	update_state(0)


# Using _input because we want to pause the timer on ALL mouse down
# (e.g. when user is scrubbing through timeline)
var pause_cache: bool
func _input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		pause_cache = GUI.get_paused()
		GUI.set_paused(true)
	elif event.is_action_released("cam_drag"):
		GUI.set_paused(pause_cache)


func update_state(state_num: int):
	print("Updating to state: ", state_num)
	
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if timeline max_value is set properly
	
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"], state["players"])


func fill_tilemaps(map: Dictionary, players: Array):
	var tileset = base_map.tile_set
	
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			base_map.set_cell(x, y, map["tiles"][y][x]["type"])
	
	# Applies auto-tiling rules
	base_map.update_bitmask_region()
	
	
	# Move characters
	for i in range(player_sprites.size()):
		var player : AnimatedSprite = player_sprites[i]
		var tween : Tween = player_tweens[i]
		var new_map_pos = players[i]["position"]
		if !new_map_pos or !player or !tween: break
		new_map_pos = Vector2(new_map_pos['x'], new_map_pos['y'])
		
		var new_world_pos = base_map.map_to_world(new_map_pos)
		
		var direction = new_world_pos - player.position
		if direction == Vector2.ZERO: return #if not moving
		
		tween.remove_all()
		if tween.interpolate_property(player, 'position', 
		player.position, new_world_pos, GUI.timer.wait_time * 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			tween.start()
			
#			var anim
#			if abs(direction.y) - abs(direction.x) > 0:
#				anim = "Down" if direction.y > 0 else "up"
#			else:
#				anim = "Right" if direction.x > 0 else "Left"
#			anim += String(i+1)
#			player.animation = anim
		
#	var p1 = tileset.find_tile_by_name("Player 1")
#	var p2 = tileset.find_tile_by_name("Player 2")
#	$Map/Characters.set_cell(init_pos[0]["x"], init_pos[0]["y"], p1)
#	$Map/Characters.set_cell(init_pos[1]["x"], init_pos[1]["y"], p2)


func _on_GUI_timeline_changed(value):
	update_state(value)


func _on_GUI_game_over():
	# TODO: display some end-of-game thing
	print("GAME OVER")
	GUI.reset()
	#get_tree().quit()


func _on_pause_toggle(b : bool):
	for p in player_sprites:
		p.playing = b
