extends VBoxContainer

const ItemBox = preload("res://Scenes/GUI/ItemBox.tscn")

onready var SeedInventory = $Inventory/MarginContainer/VBoxContainer/HBoxContainer/SeedInventory
onready var HarvestedInventory = $Inventory/MarginContainer/VBoxContainer/HBoxContainer/HarvestedInventory
onready var InventoryValue = $Inventory/MarginContainer/VBoxContainer/InventoryValue

func _ready():
	for crop in Global.CropType.keys():
		var seedSlot = ItemBox.instance()
		seedSlot.name = crop
		
		var harvestedSlot = ItemBox.instance()
		harvestedSlot.name = crop
		
		SeedInventory.add_child(seedSlot, true)
		HarvestedInventory.add_child(harvestedSlot, true)


func set_player_info(player_info):
	# Fill in Player Name text
	$NameContainer/Name.set_text(player_info["name"])
	
	# Fill in Player Money text
	$MoneyContainer/Money.set_text("$ %d" % player_info["money"])
	
	# TODO: Fill in Player Item sprite
	# TODO: Fill in Player Upgrade sprite
	
	# Fill in Player Inventory boxes
	for item in SeedInventory.get_children():
		# TODO: check only needed while we have extra inventory boxes
		if player_info["seedInventory"].keys().has(item.name):
			item.set_text(String(player_info["seedInventory"][item.name]))
	
	for item in HarvestedInventory.get_children():
		# TODO: check only needed while we have extra inventory boxes
		if player_info["harvestedInventoryTotals"].keys().has(item.name):
			item.set_text(String(player_info["harvestedInventoryTotals"][item.name]))
	
	# Fill in inventory value
	InventoryValue.text = "Value: $%d" % player_info["inventoryValue"]
