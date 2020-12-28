extends Node2D

var gamelog: Dictionary

func _ready():
	$FileDialog.connect("gamelog_ready", self, "_on_gamelog_ready")
	$FileDialog.popup()


func _on_gamelog_ready(_gamelog):
	if _gamelog == null or not JsonTranslator.valid_gamelog(_gamelog):
		print("Invalid gamelog")
		get_tree().quit()
	else:
		gamelog = _gamelog
		print(gamelog)
