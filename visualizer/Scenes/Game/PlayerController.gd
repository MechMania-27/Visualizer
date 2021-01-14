extends Node2D

export(Array, NodePath) var player_nodes

var player_sprites: Array = []
var speed: float = 1 setget change_speed
const POS_ERROR = Vector2.INF


func _ready():
	
	for path in player_nodes:
		if !path: continue
		var p = get_node(path)
		if p is PlayerSprite:
			player_sprites.append(p)
			
		
	


# Move each player to new position smoothly, 
# by default taking 0.7 seconds to move to new position (value in PlayerSprite.gd)
func move_characters(player_info: Array, tilemap: TileMap):
	
	for i in range(player_sprites.size()):
		
		if !player_info[i] or !player_sprites[i] is PlayerSprite: break
		
		var new_world_pos = _get_player_position(player_info[i], tilemap)
		if new_world_pos == POS_ERROR: break
		player_sprites[i].move_to(new_world_pos)
		
	


# Instantly update positions
func move_instant(player_info: Array, tilemap: TileMap):
	
	for i in range(player_sprites.size()):
		
		if !player_info[i] or !player_sprites[i] is PlayerSprite: break
		var player : PlayerSprite = player_sprites[i]
		
		var new_world_pos = _get_player_position(player_info[i], tilemap)
		if new_world_pos == POS_ERROR: break
		
		player.tween.remove_all()
		player.position = new_world_pos
		player.next_pos = new_world_pos
		
	


# Stop smooth movement and instantly moves to destination instead
func smooth_instant():
	for p in player_sprites:
		p.tween.remove_all()
		p.position = p.next_pos


func _get_player_position(player_info: Dictionary, tilemap: TileMap) -> Vector2:
	
	var new_board_pos = player_info["position"]
	if !new_board_pos: return POS_ERROR
	
	new_board_pos = Vector2(new_board_pos['x'], new_board_pos['y'])
	return tilemap.map_to_world(new_board_pos)


# Changes time for players to move
func change_speed(new: float):
	speed = new
	for p in player_sprites:
		p.tween.playback_speed = new
	
