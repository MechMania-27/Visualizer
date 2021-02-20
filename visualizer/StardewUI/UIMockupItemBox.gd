tool
extends PanelContainer


export var count: int = 0 setget _set_count

func _set_count(value: int):
	count = value
	$Control/Label.text = str(value)
