extends Node2D

onready var player_sprites = [$Player1, $Player2]
onready var speed: float = 1 setget change_speed

# Move each player to new position, 
# by default taking 0.5 seconds to move to new position (value in PlayerSprite.gd)
func move_characters(player_info: Array):
	if !get_parent().get_node("Base"): return
	
	for i in range(player_sprites.size()):
		
		if !player_info[i] or !player_sprites[i] is PlayerSprite: break
		
		var new_world_pos = _get_player_position(player_info[i])
		player_sprites[i].move_to(new_world_pos)
		
	


# Changes time for players to move
# Ex: 
# 1 = 0.5 seconds
# 2 = 0.25 seconds
func change_speed(new: float):
	speed = new
	for p in player_sprites:
		p.tween.playback_speed = new


# Instantly update positions
func move_instant(player_info: Array):
	
	for i in range(player_sprites.size()):
		
		if !player_info[i] or !player_sprites[i] is PlayerSprite: break
		
		var new_world_pos = _get_player_position(player_info[i])
		if !new_world_pos: break
		player_sprites[i].position = new_world_pos
		
	


func _get_player_position(player_info: Dictionary):
	if !get_parent().get_node("Base"): return
	
	var new_board_pos = player_info["position"]
	if !new_board_pos: return
	
	new_board_pos = Vector2(new_board_pos['x'], new_board_pos['y'])
	return get_parent().Base.map_to_world(new_board_pos)

