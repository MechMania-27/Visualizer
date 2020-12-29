extends FileDialog

signal gamelog_ready(gamelog)

func _on_FileDialog_file_selected(path):
	var gamelog = JsonTranslator.parse_json(path)
	emit_signal("gamelog_ready", gamelog)
