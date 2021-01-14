extends Node2D

onready var Base = $Base
onready var PlayerController = $Crops/PlayerController

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
	fill_tilemaps(state["tileMap"])
	
	if instant_update:
		PlayerController.move_instant(state["players"], Base)
	else:
		PlayerController.move_characters(state["players"], Base)
	


func fill_tilemaps(map: Dictionary):
	#var tileset = Base.tile_set
	
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			Base.set_cell(x, y, map["tiles"][y][x]["type"])
	
	# Applies auto-tiling rules
	Base.update_bitmask_region()
	


func _on_paused():
	PlayerController.smooth_instant()
