extends "res://addons/gut/test.gd"

func before_each():
	pass

func after_each():
	pass

func before_all():
	pass

func after_all():
	pass

func test_json_load():
	var gamelog = JsonTranslator.parse_json("res://test/inputs/gamelog_1.json")
	assert_true(gamelog is Dictionary, "Game log did not load as Dictionary")
	
	var gamelog_keys = ["tileMap", "playerNames", "initPlayersPos", "states"]
	for key in gamelog_keys:
		assert_has(gamelog.keys(), key)
