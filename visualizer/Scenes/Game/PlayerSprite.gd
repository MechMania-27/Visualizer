extends AnimatedSprite
class_name PlayerSprite

const DEFAULT_DURATION : float = 0.7
onready var tween = $Tween
onready var next_pos : Vector2 = position

# Moves player to new x pos first
func move_to(new_pos: Vector2):
	
	var x_distance = abs(position.x - new_pos.x) 
	var total_distance = abs(position.y - new_pos.y) + x_distance
	if total_distance == 0: return
	
	var duration = x_distance / total_distance
	duration *= DEFAULT_DURATION
	
	tween.remove_all()
	if tween.interpolate_property(self, 'position', 
	position, Vector2(new_pos.x, position.y), duration, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		
		if tween.is_connected("tween_all_completed", self, "_secondary"):
			tween.disconnect("tween_all_completed", self, "_secondary")
		
		tween.connect("tween_all_completed", self, "_secondary", 
		[new_pos, DEFAULT_DURATION - duration], CONNECT_ONESHOT + CONNECT_DEFERRED)
		
		tween.start()
		next_pos = new_pos
		
	


# Move on y axis after x completed
func _secondary(new_pos: Vector2, duration: float):
	if tween.interpolate_property(self, 'position', 
	position, Vector2(position.x, new_pos.y), duration, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		tween.start()
		
	
