extends AnimatedSprite
class_name PlayerSprite

# "base" because it will be set only once, and actual speed will be 
# controlled by the tween playback_speed. See BASE_SPEED in PlayerController
var base_speed: float = 1.0
export var color = "Blue"

# Orange 19ffa100 19ff0000
# Blue 190087ff
# How to have multiple radii for single player?
export(Color) var radius_color = Color("19ffa100")
export(NodePath) var protection_tilemap_path
export(NodePath) var harvest_tilemap_path
export(NodePath) var plant_tilemap_path

var protection_tilemap
var harvest_tilemap
var plant_tilemap

onready var tween = $Tween
onready var next_pos : Vector2 = position

signal move_completed

# Offset to fix a bug creating inconsistent YSorting when a player is in the 
# exact same position as a tile
const POSITION_OFFSET = Vector2(128, -70)
const SPRITE_FRONT = 0
const SPRITE_BACK = 1
const SPRITE_LEFT = 2
const SPRITE_RIGHT = 3

func _ready():
	protection_tilemap = get_node(protection_tilemap_path)
	harvest_tilemap = get_node(harvest_tilemap_path)
	plant_tilemap = get_node(plant_tilemap_path)
	if !protection_tilemap is TileMap or !harvest_tilemap is TileMap or !plant_tilemap is TileMap: return
	protection_tilemap.modulate = radius_color
	harvest_tilemap.modulate = radius_color
	plant_tilemap.modulate = radius_color

# Highlight protectionRadius, harvestRadius, plantRadius
func highlight_radius(center: Vector2, bounds: Rect2, protection: int, harvest: int, plant: int):
	if !protection_tilemap is TileMap or !harvest_tilemap is TileMap or !plant_tilemap is TileMap: return
	protection_tilemap.clear()
	harvest_tilemap.clear()
	plant_tilemap.clear()
	if protection + harvest + plant < 1: return
	
	draw_radius(center, bounds, protection, protection_tilemap)
	draw_radius(center, bounds, harvest, harvest_tilemap)
	draw_radius(center, bounds, plant, plant_tilemap)


# Draws a circle within field bounds
func draw_radius(center: Vector2, bounds: Rect2, r: int, map : TileMap):
	for x in range(max(center.x - r, bounds.position.x), min(center.x + r+1, bounds.size.x)):
		for y in range(max(center.y - r, bounds.position.y), min(center.y + r+1, bounds.size.y)):
			if abs(x - center.x) + abs(y - center.y) < r:
				map.set_cell(x,y, Global.TileType.RADIUS)


# Moves player to new x pos first
func move_to(new_pos: Vector2):
	new_pos += POSITION_OFFSET
	var x_distance = abs(position.x - new_pos.x) 
	var y_distance = abs(position.y - new_pos.y)
	
	if y_distance + x_distance == 0:
		emit_signal("move_completed")
		return
	
	var x_duration = x_distance / base_speed
	var y_duration = y_distance / base_speed
	
	tween.remove_all()
	next_pos = new_pos
	
	
	if tween.interpolate_property(self, 'position', 
			position, Vector2(new_pos.x, position.y), x_duration, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		
		if tween.is_connected("tween_all_completed", self, "_secondary"):
			tween.disconnect("tween_all_completed", self, "_secondary")
		
		if tween.is_connected("tween_all_completed", self, "emit_signal"):
			tween.disconnect("tween_all_completed", self, "emit_signal")
		
		if y_duration == 0:
			tween.connect("tween_all_completed", self, "emit_signal", 
				["move_completed"], CONNECT_ONESHOT + CONNECT_DEFERRED)
		else: 
			tween.connect("tween_all_completed", self, "_secondary", 
					[new_pos, y_duration], CONNECT_ONESHOT + CONNECT_DEFERRED)
		tween.start()
		if x_duration == 0: return
		var anim_name = color
		anim_name += "Left" if position.x - new_pos.x > 0 else "Right"
		animation = anim_name
		playing = true
	else:
		# X delta is ~0, skip to _secondary
		_secondary(new_pos, y_duration)


# Move on y axis after x completed
func _secondary(new_pos: Vector2, duration: float):
	if tween.interpolate_property(self, 'position', 
			position, Vector2(position.x, new_pos.y), duration, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		
		tween.connect("tween_all_completed", self, "emit_signal", 
				["move_completed"], CONNECT_ONESHOT + CONNECT_DEFERRED)
		tween.start()
		var anim_name = color
		anim_name += "Up" if position.y - new_pos.y > 0 else "Down"
		animation = anim_name
		playing = true
	else:
		# Y delta is ~0, we're done
		emit_signal("move_completed")


func _on_Player1_move_completed():
	playing = false
	var anim_name = color + "Idle"
	if animation.ends_with("Up"): anim_name += "Up"
	elif animation.ends_with("Down"): anim_name += "Down"
	elif animation.ends_with("Left"):anim_name += "Left"
	else: anim_name += "Right"
	animation = anim_name
