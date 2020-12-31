extends Node2D

onready var Base = $Base
onready var player_sprites = [$Player1, $Player2]
onready var player_tween = $Tween
var update_time : float = 1

func get_bounds() -> Rect2:
	var tilemap = Base
	var bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D( \
			Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), \
			Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2() \
			)
	return Rect2(cell_to_pixel * bounds.position, cell_to_pixel * bounds.size)


func update_state(state_num: int, instant_update: bool = false):
	print("Updating to state: ", state_num)
	
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if timeline max_value is set properly
	
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"], state["players"], instant_update)


func fill_tilemaps(map: Dictionary, players: Array, instant : bool = false):
	#var tileset = Base.tile_set
	
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			Base.set_cell(x, y, map["tiles"][y][x]["type"])
	
	# Applies auto-tiling rules
	Base.update_bitmask_region()
	
	move_characters(0 if instant else update_time * 0.5, players)
	


func move_characters(duration : float, players: Array):
	player_tween.remove_all()
	for i in range(player_sprites.size()):
		var player : AnimatedSprite = player_sprites[i]
		
		var new_map_pos = players[i]["position"]
		if !new_map_pos or !player: break
		
		new_map_pos = Vector2(new_map_pos['x'], new_map_pos['y'])
		var new_world_pos = Base.map_to_world(new_map_pos)
		
		var direction = new_world_pos - player.position
		if direction == Vector2.ZERO: continue #if not moving
		
		if player_tween.interpolate_property(player, 'position', 
		player.position, new_world_pos, duration, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			pass
			var anim
			if abs(direction.y) - abs(direction.x) > 0:
				anim = "Down" if direction.y > 0 else "up"
			else:
				anim = "Right" if direction.x > 0 else "Left"
			anim += String(i+1)
			var f = player.frame
			player.animation = anim
			player.frame = f
			
	player_tween.start()


func _on_pause_toggle(playing : bool):
	for p in player_sprites:
		p.playing = playing
	
