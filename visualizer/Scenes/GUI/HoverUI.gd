extends CanvasLayer

export(NodePath) var Crop_Tilemap
export(Array, NodePath) var Player_Nodes

const SNAP = Vector2(32, 32)
const OFFSET = Vector2(25,5)
const PLAYERSPRITE_SIZE = Vector2(32, 32)
const ANIM_ENTER = "Enter"
const ANIM_EXIT = "Exit"

onready var Anim = $AnimationPlayer
onready var CropInfo = $Node2D/HBoxContainer/LeftBox/CropInfo
onready var PlayerInfo = $Node2D/HBoxContainer/RightBox/PlayerInfo
onready var ItemInfo = $Node2D/HBoxContainer/RightBox/ItemInfo
onready var Box = $Node2D/HBoxContainer
onready var LeftInfoBox = $Node2D/HBoxContainer/LeftBox
onready var RightInfoBox = $Node2D/HBoxContainer/RightBox
onready var Positioner = $Node2D
onready var info_boxes = [CropInfo, PlayerInfo, ItemInfo]

onready var appear_radius = Box.rect_size.x * 1.5

var Crops
var players = []
#var prev_showed = false


func _ready():
	#if !Crop_Tilemap or !has_node(Crop_Tilemap): pass
	Box.hide()
	Crops = get_node(Crop_Tilemap)
	for p in Player_Nodes:
		players.append(get_node(p))
	

# Checks what the mouse is hovering over to display their info
func select_object():
	
	var global_pos = (Box.get_global_mouse_position()) # Window position
	var local_pos = Crops.get_local_mouse_position() # Game position
	var tilemap_pos = Crops.world_to_map(local_pos) # Tilemap position
	
	
	for i in range(0, info_boxes.size()):
		info_boxes[i].hide()
	RightInfoBox.hide()
	LeftInfoBox.hide()
	
	var showing = false
	var box_length = 0
	
	# Finds if a crop is selected
	var selected_crop = Crops.get_cellv(tilemap_pos)
	if selected_crop != -1:
		CropInfo.show()
		LeftInfoBox.show()
		
		var tile = Global.gamelog["states"][Global.current_turn]["tileMap"]["tiles"]
		tile = tile[tilemap_pos.y][tilemap_pos.x]
		
		CropInfo.set_name(tile["crop"]["type"].to_lower().capitalize())
		CropInfo.set_stage(tile["crop"]["growthTimer"])
		# No price found in gamelog, need something with price data
		#CropInfo.set_price(123)
		
		showing = true
		box_length += LeftInfoBox.rect_size.x
		
		
	
	# Finds if a player is selected
	for player in players:
		var pos = player.position
		var collision = Rect2(pos, Vector2(pos.x + PLAYERSPRITE_SIZE.x, pos.y + PLAYERSPRITE_SIZE.y))
		
		var x = collision.position.x <= local_pos.x and collision.size.x >= local_pos.x
		var y = collision.position.y <= local_pos.y and collision.size.y >= local_pos.y
		
		if x and y: #collision.has_point(local_pos): does not always work properly
			
			PlayerInfo.show()
			RightInfoBox.show()
			
			var node_name = player.name
			var player_state = Global.gamelog["states"][Global.current_turn]\
			['p' + node_name.right(node_name.length() - 1)]
			
			PlayerInfo.set_name(player_state["name"])
			PlayerInfo.set_money(player_state["money"])
			
			showing = true
			box_length += RightInfoBox.rect_size.x
			
			
		
	
	Positioner.global_position = (global_pos + OFFSET)
	
	# max func is a quick bug fix where var maximum 
	# would be incorrect first time since text hadn't updated to change size yet
	var box_size = Vector2(max(box_length, 155), Box.rect_size.y)
	var maximum = get_viewport().get_visible_rect().size - box_size - OFFSET
	
	Positioner.global_position.x = clamp(Positioner.global_position.x, 0, maximum.x)
	Positioner.global_position.y = clamp(Positioner.global_position.y, 0, maximum.y)
	
	if showing:
		Anim.stop(true)
		Anim.play(ANIM_ENTER)
	
	#prev_showed = showing
	


func _input(event):
	if Input.is_action_just_released("lmb"):
		select_object()
#	elif Box.visible and event is InputEventMouseMotion:
#		if Positioner.global_position.distance_to(event.position) > appear_radius \
#			and Anim.current_animation != ANIM_EXIT and Anim.get_queue().size() < 1:
#			Anim.queue(ANIM_EXIT)


func _on_PanelContainer_resized():
	if !Box: return
	appear_radius = Box.rect_size.x * 1.2

