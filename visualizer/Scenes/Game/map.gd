extends Node2D

export var TILE_BOUNDS_EXTEND: Vector2 = Vector2(10, 10)

var Harvests = {
	Global.CropType.NONE : preload("res://Assets/Images/OrangeFarmer.png"),
	Global.CropType.CORN : preload("res://Assets/Inventory/Harvested Crops/CornHarvested.png"),
	Global.CropType.GRAPE : preload("res://Assets/Inventory/Harvested Crops/GrapeHarvested.png"),
	Global.CropType.POTATO : preload("res://Assets/Inventory/Harvested Crops/PotatoHarvested.png"),
	Global.CropType.JOGAN_FRUIT : preload("res://Assets/Inventory/Harvested Crops/JoganHarvested.png"),
	Global.CropType.DUCHAM_FRUIT : null,#preload(""),
	Global.CropType.PEANUT : preload("res://Assets/Inventory/Harvested Crops/PeanutHarvested.png"),
	Global.CropType.QUADROTRITICALE : preload("res://Assets/Inventory/Harvested Crops/WheatHarvested.png"),
	Global.CropType.GOLDEN_CORN : preload("res://Assets/Inventory/Harvested Crops/GoldenHarvested.png")
}

onready var Game = get_parent()
onready var Base = $Base
onready var PlayerController = $Crops/PlayerController
onready var Crops = $Crops
onready var Player1 = $Crops/Player1
onready var Player2 = $Crops/Player2
var CropHarvestAnim = preload("res://Scenes/GUI/HarvestedCrop.tscn")

var map_bounds

signal move_completed


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
	
	var global_bounds_extend = TILE_BOUNDS_EXTEND * tilemap.cell_size * tilemap.scale
	map_bounds = Rect2((cell_to_pixel * bounds.position) - global_bounds_extend, 
			(cell_to_pixel * bounds.size) + (global_bounds_extend * 2))
	
	return map_bounds


func update_state(state_num: int, instant_update: bool = false):
	if state_num >= len(Global.gamelog["states"]):
		return # Should never reach here if timeline max_value is set properly
	
	Global.current_turn = state_num
	var state = Global.gamelog["states"][state_num]
	fill_tilemaps(state["tileMap"], instant_update)
	
	if instant_update:
		PlayerController.move_instant(state["p1"]["position"], 
				state["p2"]["position"])
	else:
		PlayerController.move_smooth(state["p1"]["position"], 
				state["p2"]["position"])


func fill_tilemaps(map: Dictionary, instant_update : bool = false):
	# Fill in base layer
	for x in range(0, map["mapWidth"]):
		for y in range(0, map["mapHeight"]):
			var tile: Dictionary = map["tiles"][y][x]
			
			var base_cell = Global.TileType.get(tile["type"])
			if base_cell == Global.TileType.GREEN_GROCER:
				$Items1.set_cell(x,y,Global.Item.GREEN_GROCER)
				$Base.set_cell(x,y,Global.TileType.GRASS)
				continue
			
			$Base.set_cell(x, y, base_cell)
			
			var crop_type = Global.CropType.get(tile["crop"]["type"])
			if crop_type == Global.CropType.NONE:
				var crop_cell = Crops.get_cell(x,y)
				if crop_cell != -1:# and !instant_update:
					var harvested_crop = CropHarvestAnim.instance()
					harvested_crop.position = Crops.map_to_world(Vector2(x,y)) * Crops.scale
					harvested_crop.position += Vector2(16 + rand_range(-8,8),16 + rand_range(-8,8))
					harvested_crop.texture = Harvests.get(crop_cell)
					add_child(harvested_crop)
				Crops.set_cell(x, y, -1)
			else:
				Crops.set_cell(x, y, crop_type, false, false, \
						false, get_crop(tile["crop"]["growthTimer"]))
			
			var p1_item_type = Global.Item.get(tile["p1_item"])
			var p2_item_type = Global.Item.get(tile["p2_item"])
			$Items1.set_cell(x,y,p1_item_type)
			$Items2.set_cell(x,y,p2_item_type)
			
	# Applies auto-tiling rules
	$Base.update_bitmask_region(Vector2(), Vector2(map["mapWidth"], map["mapHeight"]))


func _on_Game_paused():
	PlayerController.pause()

func _on_Game_resumed():
	PlayerController.resume()


func _on_PlayerController_move_completed():
	emit_signal("move_completed")
