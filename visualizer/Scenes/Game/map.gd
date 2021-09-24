extends Node2D

export var TILE_BOUNDS_EXTEND: Vector2 = Vector2(10, 10)

onready var Game = get_parent()
onready var Base = $Base
onready var PlayerController = $Crops/PlayerController
onready var Crops = $Crops
onready var Player1 = $Crops/Player1
onready var Player2 = $Crops/Player2

var map_bounds

signal move_completed
signal map_updated


func _ready():
	$Base.clear()
	$Crops.clear()


func get_crops_tilemap() -> Node:
	return Crops


func get_players_array() -> Array:
	return [Player1, Player2]


# Maps from crop growth stage to atlas sprite coordinate
func get_crop(stage: int) -> Vector2:
	# TODO: This will have to be changed for the final sprite sheet
	return Vector2(2 - stage, 0)


func get_bounds() -> Rect2:
	if map_bounds: return map_bounds
	
	var tilemap: TileMap = $Base
	var bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D( \
			Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), \
			Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2() \
			)
	
	# Add buffer around
	bounds.position -= TILE_BOUNDS_EXTEND
	bounds.size += 2*TILE_BOUNDS_EXTEND
	
	# Convert to global coordinates
	map_bounds = Rect2(cell_to_pixel * bounds.position, cell_to_pixel * bounds.size)
	
	return map_bounds


func update_state(state_num: int, instant_update: bool = false):
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if timeline max_value is set properly
	
	Global.current_turn = state_num
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"])
	
	if instant_update:
		PlayerController.move_instant(state["p1"]["position"], 
				state["p2"]["position"])
	else:
		PlayerController.move_smooth(state["p1"]["position"], 
				state["p2"]["position"])
	
	emit_signal("map_updated")


func fill_tilemaps(map: Dictionary):
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			var tile: Dictionary = map["tiles"][y][x]
			$Base.set_cell(x, y, Global.TileType.get(tile["type"]))
			
			var crop_type = Global.CropType.get(tile["crop"]["type"])
			if crop_type == Global.CropType.NONE:
				$Crops.set_cell(x, y, -1)
			else:
				var flip
				if $Crops.get_cell(x,y) != -1:
					flip = $Crops.is_cell_x_flipped(x,y)
				else:
					flip = true if randf() > 0.5 else false
				
				# Check if crop should be wilted
				var crop_name = tile["crop"]["type"]
				if tile["crop"]["value"] == 0 and tile["crop"]["growthTimer"] == 0:
					crop_name = "WILTED_" + crop_name
				
				var tile_id = $Crops.tile_set.find_tile_by_name(crop_name)
				$Crops.set_cell(x, y, tile_id, flip, false, \
						false, get_crop(tile["crop"]["growthTimer"]))
	
	# Applies auto-tiling rules
	$Base.update_bitmask_region()


func _on_Game_paused():
	PlayerController.pause()

func _on_Game_resumed():
	PlayerController.resume()


func _on_PlayerController_move_completed():
	emit_signal("move_completed")
