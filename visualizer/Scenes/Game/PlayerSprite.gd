extends AnimatedSprite
class_name PlayerSprite

# "base" because it will be set only once, and actual speed will be 
# controlled by the tween playback_speed. See BASE_SPEED in PlayerController
var base_speed: float = 1.0

onready var tween = $Tween
onready var next_pos : Vector2 = position

signal move_completed

# Offset to fix a bug creating inconsistent YSorting when a player is in the 
# exact same position as a tile
const POSITION_OFFSET = Vector2(0, -0.01)

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
		
		tween.connect("tween_all_completed", self, "_secondary", 
				[new_pos, y_duration], CONNECT_ONESHOT + CONNECT_DEFERRED)
		tween.start()
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
	else:
		# Y delta is ~0, we're done
		emit_signal("move_completed")
