extends Camera2D

# From https://www.braindead.bzh/entry/godot-interactive-camera2d

export var MAX_ZOOM_LEVEL = 0.25
export var MIN_ZOOM_LEVEL = 1.0
export var ZOOM_INCREMENT = 0.05

signal moved
signal zoomed

var _current_zoom_level = 1
var _drag = false
var tilemap_bounds: Rect2


func _input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		_drag = true
	elif event.is_action_released("cam_drag"):
		_drag = false
	elif event.is_action("cam_zoom_in"):
		_update_zoom(-ZOOM_INCREMENT, get_local_mouse_position())
	elif event.is_action("cam_zoom_out"):
		_update_zoom(ZOOM_INCREMENT, get_local_mouse_position())
	elif event is InputEventMouseMotion && _drag:
		set_offset(get_offset() - event.relative * _current_zoom_level)
		
		# Keep camera in bounds
		# (offset is positive going left or up)
		# TODO: account for zoom level
		var max_x = self.zoom.x * get_viewport_rect().end.x - tilemap_bounds.end.x
		var min_x = self.zoom.x * get_viewport_rect().position.x - tilemap_bounds.position.x
		var max_y = self.zoom.y * get_viewport_rect().end.y - tilemap_bounds.end.y
		var min_y = self.zoom.y * get_viewport_rect().position.y - tilemap_bounds.position.y
		
		if -get_offset().x > max_x:
			self.offset.x = -max_x
		elif -get_offset().x < min_x:
			self.offset.x = -min_x
		if -get_offset().y > max_y:
			self.offset.y = -max_y
		elif -get_offset().y < min_y:
			self.offset.y = -min_y
		
		emit_signal("moved")


func _update_zoom(incr: float, zoom_anchor: Vector2):
	var old_zoom = _current_zoom_level
	_current_zoom_level += incr
	if _current_zoom_level < MAX_ZOOM_LEVEL:
		_current_zoom_level = MAX_ZOOM_LEVEL
	elif _current_zoom_level > MIN_ZOOM_LEVEL:
		_current_zoom_level = MIN_ZOOM_LEVEL
	if old_zoom == _current_zoom_level:
		return
	
	var zoom_center = zoom_anchor - get_offset()
	var ratio = 1-_current_zoom_level/old_zoom
	set_offset(get_offset() + zoom_center*ratio)
	
	set_zoom(Vector2(_current_zoom_level, _current_zoom_level))
	emit_signal("zoomed")
