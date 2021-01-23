extends BoxContainer
#warning-ignore-all:return_value_discarded

onready var Text = $HBoxContainer/VBoxContainer/Label
onready var Progress = $HBoxContainer/VBoxContainer/ProgressBar
onready var Anim = $HBoxContainer/TextureRect/AnimationPlayer

func _ready():
	hide()
	Progress.value = 0
	Global.connect("progress_changed", self, "_on_Global_progress_changed")
	Global.connect("progress_text_changed", self, "set_text")
	Global.connect("verify_gamelog_start", self, "_on_verify_gamelog_start")
	Global.connect("gamelog_check_failed", self, "_on_verify_gamelog_failed")
	


func set_text(text: String):
	Text.text = text


func _on_Global_progress_changed(percent: float):
	Progress.value = Progress.max_value * percent


func _on_verify_gamelog_start():
	mouse_filter = Control.MOUSE_FILTER_STOP
	Anim.play("loop")
	show()


func _on_verify_gamelog_failed():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Anim.stop()
