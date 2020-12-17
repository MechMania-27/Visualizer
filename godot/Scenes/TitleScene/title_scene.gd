extends Control


func _ready():
	var start_button = $Menu/CenterRow/Buttons/StartButton
	start_button.connect("pressed", self, "_on_StartButton_pressed")
	
	$Menu/CenterRow/Buttons/QuitButton.connect("pressed", self, "_on_QuitButton_pressed")

func _on_StartButton_pressed():
	$FileDialog.popup()

func _on_FileDialog_file_selected(path: String):
	var _gamelog = JsonTranslator.parse_json(path)
	if _gamelog == null or not JsonTranslator.valid_gamelog(_gamelog):
		print("Invalid Game Log")
		$FileDialog.set_title("Select a Valid Game Log")
	else:
		Global.gamelog = _gamelog
		get_tree().change_scene("res://Scenes/Game/Game.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
