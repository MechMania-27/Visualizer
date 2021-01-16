extends Control

onready var status = $Menu/HBoxContainer/Status

onready var file_thread := Thread.new()


func _on_StartButton_pressed():
	$FileDialog.popup()


func _on_QuitButton_pressed():
	get_tree().quit()


# Called by file_thread, or deferred in Web builds
func _on_gamelog_ready():
	if file_thread.is_active():
		file_thread.wait_to_finish()
	
	get_tree().change_scene("res://Scenes/Game/Game.tscn")


func _on_FileDialog_file_selected(path: String):
	status.set_text("Reading game log file...")
	file_thread.start(self, "read_gamelog_file", path)


func _on_FileDialog_reading_begun():
	# This doesn't seem to actually work
	status.set_text("Reading game log file...")
	yield(get_tree(), "idle_frame")


func _on_FileDialog_file_read(data: PoolByteArray):
	call_deferred("check_gamelog", data.get_string_from_utf8())


func read_gamelog_file(path: String):
	var file := File.new()
	file.open(path, file.READ)
	var text: String = file.get_as_text()
	file.close()
	
	check_gamelog(text)


func check_gamelog(text: String):
	status.set_text("Verifying game log format...")
	
	# Idle_frame yield is only applicable from call_deferred, NOT thread
	if not file_thread.is_active():
		yield(get_tree(), "idle_frame")
	
	var json_result = JSON.parse(text)
	if json_result.error != OK:
		return null
	
	# Check validity
	var _gamelog = json_result.result
	if _gamelog == null or not Global.valid_gamelog(_gamelog):
		printerr("Invalid Game Log")
		$FileDialog.set_title("Select a Valid Game Log")
	else:
		Global.gamelog = _gamelog
		call_deferred("_on_gamelog_ready")


func _exit_tree():
	if file_thread.is_active():
		file_thread.wait_to_finish()
