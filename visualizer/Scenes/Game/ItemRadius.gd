extends TileMap

var item_radius = {
	Global.Item.NONE: -1,
	Global.Item.FERTILITY_IDOL : 3,
	Global.Item.SCARECROW : 2,
	Global.Item.PESTICIDE : 0,
}


# Draws square with sides 2x the radius
func draw_radius(center: Vector2, bounds: Rect2, item: int = -1, square: bool = true):
	var r = item_radius.get(item, Global.Item.NONE)
	if r < 0: return
	if square:
		for x in range(max(center.x - r, bounds.position.x), min(center.x + r+1, bounds.size.x)):
			for y in range(max(center.y - r, bounds.position.y), min(center.y + r+1, bounds.size.y)):
				set_cell(x,y,Global.TileType.RADIUS)
	else:
		for x in range(max(center.x - r, bounds.position.x), min(center.x + r+1, bounds.size.x)):
			for y in range(max(center.y - r, bounds.position.y), min(center.y + r+1, bounds.size.y)):
				if abs(x - center.x) + abs(y - center.y) < r:
					set_cell(x,y,Global.TileType.RADIUS)
