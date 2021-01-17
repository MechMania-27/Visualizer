extends PanelContainer

onready var NameLabel: Label = $Container/Top/Name
onready var GoldLabel: Label = $Container/Top/HSplitContainer/GoldCount
onready var Items: GridContainer = $Container/Items

func _ready():
	# TODO: Should we fill in the Items container procedurally on ready?
	# Or should we stick with the current method of using the editor?
	
	set_money(0)
	
	for key in Global.CropType.keys():
		set_inventory(key, true, 0)
		set_inventory(key, false, 0)


func set_info(player_info: Dictionary):
	set_name(player_info["name"])
	set_money(player_info["money"])
	# TODO: update inventory once in Player JSON spec
	# TODO: update item/upgrade once we add UI for that


func set_name(name: String):
	NameLabel.set_text(name)


func set_money(money: float):
	GoldLabel.set_text("$%.2f" % money)


func set_inventory(crop: String, is_seed: bool, value: int):
	if not Global.CropType.has(crop) or crop == "NONE":
		return
	
	var path: String = crop
	if is_seed:
		path += "_SEED"
	
	var item_box: ItemBox = Items.get_node(path)
	
	if item_box != null:
		item_box.set_text(str(value))
