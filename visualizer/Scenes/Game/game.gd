extends Node2D

var cam_bounds: Rect2
onready var Map = $Map
onready var GUI = $GUI
onready var camera = $Camera

func _ready():
	Map.update_time = GUI.timer.wait_time
	Map.update_state(0)
	camera.refresh_bounds()


# Using _input because we want to pause the timer on ALL mouse down
# (e.g. when user is scrubbing through timeline)
var pause_cache: bool
func _input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		pause_cache = GUI.get_paused()
		GUI.set_paused(true)
	elif event.is_action_released("cam_drag"):
		GUI.set_paused(pause_cache)

var prev_value = 0
func _on_GUI_timeline_changed(value):
	var instant = abs(value - prev_value) > 1
	Map.update_state(value, instant)
	prev_value = value


func _on_GUI_game_over():
	# TODO: display some end-of-game thing
	print("GAME OVER")
	GUI.reset()
	#get_tree().quit()


