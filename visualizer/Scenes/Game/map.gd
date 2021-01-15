extends Node2D

onready var Base = $Base
onready var PlayerController = $Crops/PlayerController

signal move_completed

# Maps from crop growth stage to atlas sprite coordinate
func get_crop(stage: int) -> Vector2:
	# TODO: This will have to be changed for the final sprite sheet
	return Vector2(2 - stage, 0)


func get_bounds() -> Rect2:
	var tilemap = Base
	var bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D( \
			Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), \
			Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2() \
			)
	return Rect2(cell_to_pixel * bounds.position, cell_to_pixel * bounds.size)


func update_state(state_num: int, instant_update: bool = false):
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if timeline max_value is set properly
	
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"])
	
	if instant_update:
		PlayerController.move_instant(state["p1"]["position"], 
				state["p2"]["position"])
	else:
		PlayerController.move_smooth(state["p1"]["position"], 
				state["p2"]["position"])


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
				$Crops.set_cell(x, y, crop_type, false, false, \
						false, get_crop(tile["crop"]["growthTimer"]))
	
	# Applies auto-tiling rules
	$Base.update_bitmask_region()


func _on_paused():
	PlayerController.pause()

func _on_resumed():
	PlayerController.resume()


func _on_PlayerController_move_completed():
	emit_signal("move_completed")
