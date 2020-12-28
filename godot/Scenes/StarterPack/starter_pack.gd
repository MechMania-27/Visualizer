extends Node2D

onready var text_edit: TextEdit = $GUI/VBoxContainer/Controls/TextEdit

func _on_Button_pressed():
	print("Text entered:\n", text_edit.text, "\n")
	text_edit.text = ""
