extends Control

func _ready():
	if Global.use_js:
		$MarginContainer/Menu/CenterRow/Buttons/QuitButton.visible = false


func _on_StartButton_pressed():
	$FileDialog.popup()


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_FileDialog_gamelog_ready():
	get_tree().change_scene("res://Scenes/Game/Game.tscn")
