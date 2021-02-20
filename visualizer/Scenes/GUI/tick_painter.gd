tool
extends Control

export var past_tick: Texture
export var future_tick: Texture

# TODO: how to get this from self?
export var grabber: Texture

onready var timeline: HSlider = get_parent()


# Override draw to add better ticks!
func _draw():
	# Replace default ticks with different ticks for 
	# behind and in front of grabber
	var num_past = (timeline.value / timeline.max_value) * timeline.tick_count
	var num_future = timeline.tick_count - num_past
	
	var tick_space_width = self.get_rect().size.x - grabber.get_width()/2
	
	# TODO: ensure that *something* is drawn beneath the full grabber at all
	# times. (Currently and the very final edge, tractor goes past the last tick)
	# solution is to have some ticks which are *always* past/future at the
	# start/end of the grabber track
	
	for i in range(0, timeline.tick_count):
		var texture = past_tick
		if(i > num_past):
			texture = future_tick
		
		# Draw all with baseline at 0
		var height = self.get_rect().size.y - texture.get_height()
		
		var x = i * (tick_space_width / timeline.tick_count)
		draw_texture(texture, Vector2(x, height))


func _on_Timeline_value_changed(_value):
	update()
