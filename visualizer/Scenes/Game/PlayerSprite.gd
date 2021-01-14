extends AnimatedSprite
class_name PlayerSprite

export var position_offset: Vector2 = Vector2(0, -0.01)

#const MAX_DURATION: float = 0.9

# Assumming 32x32 tiles, 7 tiles per second
# Speed should presumably be enough to reach furthest move distance within a turn
const DEFAULT_SPEED: float = 224.0 

onready var tween = $Tween
onready var next_pos : Vector2 = position

#warning-ignore:unused_signal
signal move_completed

# Moves player to new x pos first
func move_to(new_pos: Vector2):
	new_pos += position_offset
	var x_distance = abs(position.x - new_pos.x) 
	var y_distance = abs(position.y - new_pos.y)
	#var total_distance = y_distance + x_distance
	if y_distance + x_distance == 0: return
	
	var x_duration = x_distance / DEFAULT_SPEED
	var y_duration = y_distance / DEFAULT_SPEED
	
#	var x_max_duration = x_distance / total_distance
#	x_max_duration *= MAX_DURATION
#
#	var x_tween_duration = min(x_duration, x_max_duration)
#	var y_tween_duration = min(y_duration, MAX_DURATION - x_max_duration)
	
	tween.remove_all()
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
		next_pos = new_pos
		
	


# Move on y axis after x completed
func _secondary(new_pos: Vector2, duration: float):
	if tween.interpolate_property(self, 'position', 
	position, Vector2(position.x, new_pos.y), duration, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		tween.start()
		
		tween.connect("tween_all_completed", self, "emit_signal", 
		["move_completed"], CONNECT_ONESHOT + CONNECT_DEFERRED)
		
	
