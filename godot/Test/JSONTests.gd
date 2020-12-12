extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var gamelog = JsonTranslator.parse_json("res://Test/JSONs/gamelog_1.json")
	if(not gamelog is Dictionary):
		print("FAILURE")
	print("Keys: ", gamelog.keys())
	print(gamelog.tileMap.tiles)
