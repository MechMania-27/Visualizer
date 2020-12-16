extends Control


func _ready():
	for button in $Menu/CenterRow/Buttons.get_children():
		button.connect("pressed", self, "_on_MenuButton_pressed", [button.scene_to_load])

func _on_MenuButton_pressed(scene: String):
	if scene == null or scene == "":
		get_tree().quit()
	else:
		get_tree().change_scene(scene)
