extends CanvasLayer

# Signal interface
signal timeline_changed(value)
signal game_over
signal paused
signal resumed

onready var timeline: Slider = $VBoxContainer/Controls/Timeline
onready var play_button: Button = $VBoxContainer/Controls/PlayButton


func _ready():
	timeline.max_value = len(Global.gamelog["states"])


func _on_Timeline_value_changed(value):
	emit_signal("timeline_changed", value)


func _on_PlayButton_pressed():
	if play_button.text == "Play":
		play_button.text = "Pause"
		emit_signal("resumed")
	elif play_button.text == "Pause":
		play_button.text = "Play"
		emit_signal("paused")
