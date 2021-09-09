extends Camera2D

# Adapted from https://www.braindead.bzh/entry/godot-interactive-camera2d

export var MAX_ZOOM_LEVEL = 0.1
export var MIN_ZOOM_LEVEL = 2.0
export var ZOOM_INCREMENT = 0.1

signal moved
signal zoomed

var _current_zoom_level = 1
var _drag = false
var tilemap_bounds: Rect2

onready var map: Node = get_node("../Map")


func refresh_bounds():
	tilemap_bounds = map.get_bounds()


# Use _unhandled_input so that we don't move camera if mouse-down is on GUI
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("cam_drag"):
		_drag = true
	elif event.is_action_released("cam_drag"):
		_drag = false
	elif event.is_action_pressed("cam_zoom_in"):
		_update_zoom(-ZOOM_INCREMENT, get_local_mouse_position())
	elif event.is_action_pressed("cam_zoom_out"):
		_update_zoom(ZOOM_INCREMENT, get_local_mouse_position())
	elif event is InputEventMouseMotion && _drag:
		set_offset(get_offset() - event.relative * _current_zoom_level)
		_constrain_view()
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
	_constrain_view()
	
	emit_signal("zoomed")


# Limits camera so that it is impossible to have just one of the two opposing
# edges of the tilemap off the screen. To be called after movement or zooming
func _constrain_view():
	var map: Rect2 = Rect2( \
			tilemap_bounds.position - get_offset(), tilemap_bounds.size)
	var view: Rect2 = Rect2(get_viewport_rect().position, \
			get_viewport_rect().size * _current_zoom_level)
	
	# If just one of two opposite boundaries is out of view, 
	# move the camera the shortest distance so one boundary is on the edge
	if map.end.x > view.end.x and map.position.x >= view.position.x \
			or map.position.x < view.position.x and map.end.x <= view.end.x:
		if abs(map.end.x - view.end.x) < abs(map.position.x - view.position.x):
			self.offset.x +=  map.end.x - view.end.x
		else:
			self.offset.x += map.position.x - view.position.x
	
	if map.end.y > view.end.y and map.position.y >= view.position.y \
			or map.position.y < view.position.y and map.end.y <= view.end.y:
		if abs(map.end.y - view.end.y) < abs(map.position.y - view.position.y):
			self.offset.y +=  map.end.y - view.end.y
		else:
			self.offset.y += map.position.y - view.position.y


func _on_GUI_event(event: InputEvent):
	_unhandled_input(event)
