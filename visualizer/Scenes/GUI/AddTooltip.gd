extends Node

const Tooltip = preload("res://Scenes/GUI/Tooltip.tscn")

func _make_custom_tooltip(text: String) -> Control:
	var tooltip = Tooltip.instance()
	tooltip.get_node("PanelContainer/MarginContainer/Label").set_text(text)
	return tooltip
