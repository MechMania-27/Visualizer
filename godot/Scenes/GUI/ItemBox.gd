tool
extends Node

export var texture_node : NodePath
export var text_node : NodePath 
export var texture_sprite : Texture setget set_texture

var _texture_node : TextureRect
var _text_node : Label


func _ready() -> void:
	_texture_node = get_node(texture_node)
	_text_node = get_node(text_node)
	


func set_texture(t : Texture) -> void:
	texture_sprite = t
	if _texture_node:
		_texture_node.texture = t
	


func set_text(t : String) -> void:
	if _text_node:
		_text_node.text = t
	
