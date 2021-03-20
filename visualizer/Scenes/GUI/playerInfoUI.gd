extends VBoxContainer

onready var SeedInventory = $Inventory/HBoxContainer/SeedInventory
onready var HarvestedInventory = $Inventory/HBoxContainer/HarvestedInventory

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
			print("Setting seed inventory for %s" % item.name)
			item.set_text(String(player_info["seedInventory"][item.name]))
	
	for item in HarvestedInventory.get_children():
		# TODO: check only needed while we have extra inventory boxes
		if player_info["harvestedInventoryTotals"].keys().has(item.name):
			print("Setting harvestedinventory for %s" % item.name)
			item.set_text(String(player_info["harvestedInventoryTotals"][item.name]))
