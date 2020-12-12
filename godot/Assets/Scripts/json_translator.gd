extends Node

func parse_json(filepath: String):

	var file = File.new()
	file.open(filepath, file.READ)
	var json_result = JSON.parse(file.get_as_text())
	if(json_result.error != OK):
		return null
	file.close()
	return json_result.result
