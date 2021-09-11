extends CanvasLayer

export(NodePath) var Map

#export(NodePath) var Crop_Tilemap
#export(Array, NodePath) var Player_Nodes

const SNAP = Vector2(32, 32)
const OFFSET = Vector2(25,5)
const PLAYERSPRITE_SIZE = Vector2(32, 32)
const ANIM_ENTER = "Enter"
const ANIM_EXIT = "Exit"

onready var Anim = $AnimationPlayer
onready var Box = $Node2D/HBoxContainer
onready var CropInfo = $Node2D/HBoxContainer/CropPanel/MarginContainer/CropInfo
onready var PlayerInfo = $Node2D/HBoxContainer/PlayerPanel/MarginContainer/PlayerInfo
onready var P1ItemInfo = $Node2D/HBoxContainer/ItemPanel/MarginContainer/VBoxContainer/P1ItemInfo
onready var P2ItemInfo = $Node2D/HBoxContainer/ItemPanel/MarginContainer/VBoxContainer/P2ItemInfo
onready var CropInfoBox = $Node2D/HBoxContainer/CropPanel
onready var PlayerInfoBox = $Node2D/HBoxContainer/PlayerPanel
onready var ItemInfoBox = $Node2D/HBoxContainer/ItemPanel
onready var Positioner = $Node2D

onready var appear_radius = Box.rect_size.x * 1.5

onready var item_names = Global.Item.keys()


var Crops
var players = []
#var prev_showed = false


func _ready():
	Box.hide()
	#Crops = get_node(Crop_Tilemap)
	#for p in Player_Nodes:
	#	players.append(get_node(p))
	var map = get_node(Map)
	Crops = map.get_crops_tilemap()
	players = map.get_players_array()


# Checks what the mouse is hovering over to display their info
func select_object():
	
	var global_pos = (Box.get_global_mouse_position()) # Window position
	var local_pos = Crops.get_local_mouse_position() # Game position
	var tilemap_pos = Crops.world_to_map(local_pos) # Tilemap position
	
	var tile = Global.gamelog["states"][Global.current_turn]["tileMap"]["tiles"]
	
	# returns if clicking off the field
	if tilemap_pos.y >= tile.size() or tilemap_pos.x >= tile[tilemap_pos.y].size(): return
	
	tile = tile[tilemap_pos.y][tilemap_pos.x]
	
	Positioner.global_position = (global_pos + OFFSET)
	
	Box.hide()
	PlayerInfoBox.hide()
	CropInfoBox.hide()
	ItemInfoBox.hide()
	
	var showing = false
	var box_length = 0
	
	# Finds if a crop is selected
	var selected_crop = Crops.get_cellv(tilemap_pos)
	print("CROP SELECTED: ", selected_crop)
	if selected_crop != -1:
		
		CropInfo.set_name(tile["crop"]["type"].to_lower().capitalize())
		CropInfo.set_stage(tile["crop"]["growthTimer"])
		CropInfo.set_price(Global.crop_prices[selected_crop])
		
		print(CropInfo.Name)
		
		showing = true
		box_length += CropInfoBox.rect_size.x
		CropInfoBox.show()
	
	# Finds if a player is selected
	for player in players:
		var pos = player.position
		var collision = Rect2(pos, Vector2(pos.x + PLAYERSPRITE_SIZE.x, pos.y + PLAYERSPRITE_SIZE.y))
		
		var x = collision.position.x <= local_pos.x and collision.size.x >= local_pos.x
		var y = collision.position.y <= local_pos.y and collision.size.y >= local_pos.y
		
		if x and y: #collision.has_point(local_pos): does not always work properly
			
			PlayerInfoBox.show()
			
			var node_name = player.name
			var player_state = Global.gamelog["states"][Global.current_turn]\
			['p' + node_name.right(node_name.length() - 1)]
			
			PlayerInfo.set_name(player_state["name"])
			PlayerInfo.set_money(player_state["money"])
			
			showing = true
			box_length += PlayerInfoBox.rect_size.x
			
		
	
	# Finds items selected
	var p1_item = Global.Item.get(tile["p1_item"], -1)
	var p2_item = Global.Item.get(tile["p2_item"], -1)
	if p1_item > 0:
		ItemInfoBox.show()
		P1ItemInfo.set_item_name(tile["p1_item"].capitalize(), 1)
		P1ItemInfo.set_description(Global.item_descriptions[p1_item])
		
	if p2_item > 0:
		ItemInfoBox.show()
		P2ItemInfo.set_item_name(tile["p2_item"].capitalize(), 2)
		P2ItemInfo.set_description(Global.item_descriptions[p2_item])
		
	if p1_item > 0 or p2_item > 0: 
		box_length += ItemInfoBox.rect_size.x
		showing = true
	
	# clamps menu so it doesn't go outside game window
	var box_size = Vector2(max(box_length, 15), Box.rect_size.y)
	var maximum = get_viewport().get_visible_rect().size - box_size - OFFSET
	Positioner.global_position.x = clamp(Positioner.global_position.x, 0, maximum.x)
	Positioner.global_position.y = clamp(Positioner.global_position.y, 0, maximum.y)
	
	if showing:
		Anim.stop(true)
		Anim.play(ANIM_ENTER)
		Box.show()
	
	#prev_showed = showing
	


func _input(event):
	if Input.is_action_just_released("lmb"):
		select_object()
	elif Input.is_action_just_pressed("lmb"):
		Box.hide()
#	elif Box.visible and event is InputEventMouseMotion:
#		if Positioner.global_position.distance_to(event.position) > appear_radius \
#			and Anim.current_animation != ANIM_EXIT and Anim.get_queue().size() < 1:
#			Anim.queue(ANIM_EXIT)


func _on_PanelContainer_resized():
	if !Box: return
	appear_radius = Box.rect_size.x * 1.2

