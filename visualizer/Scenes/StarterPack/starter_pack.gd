extends Node2D

# NOTE ON TESTING:
# read_line will crash if no input is received on stdin!

# NOTE ON IO:
# stdin receives game state from engine,
# stdout sends decisions to engine.
# stderr is reserved for debugging

onready var text_edit: TextEdit = $GUI/VBoxContainer/Controls/TextEdit


func _ready():
	print("READY")
	print($CLInput.test())
	print("stdin: ", $CLInput.read_line())
	print("DONE")


func _on_Button_pressed():
	print("Text entered:\n", text_edit.text, "\n")
	text_edit.text = ""
