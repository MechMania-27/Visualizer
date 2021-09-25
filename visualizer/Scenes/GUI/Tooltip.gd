extends Control

func _ready():
		
	# Let sizes update
	yield(get_tree(), "idle_frame")
	
	var transform = $PanelContainer.get_global_transform_with_canvas()
	var rect = $PanelContainer.get_global_rect()
	var end = transform.origin + rect.size
	var view = get_viewport_rect().size
	
	if end.x > view.x:
		$PanelContainer.set_global_position(transform * Vector2(view.x - end.x, 0))
	if end.y > view.y:
		$PanelContainer.set_global_position(transform * Vector2(0, view.y - end.y))
