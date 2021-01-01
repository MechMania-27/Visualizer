extends AnimatedSprite
class_name PlayerSprite

onready var tween = $Tween
export var default_duration : float = 0.5

#Moves player to new x pos first
func move_to(new_pos: Vector2):
	
	var x_distance = abs(position.x - new_pos.x) 
	var total_distance = abs(position.y - new_pos.y) + x_distance
	if total_distance == 0: return
	
	var duration = x_distance / total_distance
	duration *= default_duration
	
	if tween.interpolate_property(self, 'position', 
	position, Vector2(new_pos.x, position.y), duration, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		
		tween.connect("tween_all_completed", self, "_secondary", 
		[new_pos, default_duration - duration], CONNECT_ONESHOT + CONNECT_DEFERRED)
		
		tween.start()
		
	


#Move on y axis after x completed
func _secondary(new_pos: Vector2, duration: float):
	if tween.interpolate_property(self, 'position', 
	position, Vector2(position.x, new_pos.y), duration, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		tween.start()
		
