extends Node2D

# NOTE ON TESTING:
# read_line will crash if no input is received on stdin!

# NOTE ON IO:
# stdin receives game state from engine,
# stdout sends decisions to engine.
# stderr is reserved for debugging

onready var text_edit: TextEdit = $GUI/VBoxContainer/Controls/TextEdit
onready var Map = $Map
onready var GUI = $GUI/VBoxContainer/GameInfoUI

var input: String


func _ready():
	Global.gamelog = {
		"states": [],
	}
	
	# Communication is initiated by the bot
	# to select items, so just wait for button press

func next():
	text_edit.text = ""
	input = $CLInput.read_line()
	
	# Append this game state to the global list
	var json_result = JSON.parse(input)
	if json_result.error != OK:
		printerr("Problem with the incoming game state!")
		return
	
	var gamestate = json_result.result
	Global.gamelog["states"].append(gamestate)
	
	update_state(len(Global.gamelog["states"]) - 1, true)
	
	# printerr(input)


func update_state(value: int, instant_update: bool = false):
	if value < len(Global.gamelog["states"]):
		# Update Map
		Map.update_state(value, instant_update)
		
		# Update GUI
		GUI.set_player_info(1, Global.gamelog["states"][value]["p1"])
		GUI.set_player_info(2, Global.gamelog["states"][value]["p2"])
		
		# TODO: Should I use the GameState["turn"]?
		GUI.set_turn(value + 1)
	else:
		printerr("update_state value is out of bounds of states array!")


func _on_Button_pressed():
	print(text_edit.text);
	next()
