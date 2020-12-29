extends CanvasLayer

# Signal interface
signal timeline_changed(value)
signal game_over
signal paused
signal resumed

onready var timer: Timer = $Timer
onready var timeline: Slider = $VBoxContainer/Controls/Timeline
onready var play_button: Button = $VBoxContainer/Controls/PlayButton

# Function interface
func reset():
	timeline.value = timeline.min_value


func get_paused():
	return timer.paused


func set_paused(b: bool):
	timer.paused = b


func _ready():
	timeline.max_value = len(Global.gamelog["states"])
	timer.start()


func _on_Timer_timeout():
	if timeline.value < timeline.max_value:
		timeline.value += 1


func _on_Timeline_value_changed(value):
	if value == timeline.max_value:
		emit_signal("game_over")
	else:
		emit_signal("timeline_changed", value)


func _on_PlayButton_pressed():
	if play_button.text == "Play":
		timer.paused = false
		play_button.text = "Pause"
		emit_signal("resumed")
	elif play_button.text == "Pause":
		timer.paused = true
		play_button.text = "Play"
		emit_signal("paused")
