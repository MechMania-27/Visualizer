extends VBoxContainer


func set_player_info(player_info):
	# Fill in Player Name text
	$NameContainer/Name.set_text(player_info["name"])
	
	# Fill in Player Money text
	$MoneyContainer/Money.set_text("$ %d" % player_info["money"])
	
	# TODO: Fill in Player Item sprite
	# TODO: Fill in Player Upgrade sprite
	
	# Fill in Player Inventory boxes
	var items = get_tree().get_nodes_in_group("items")
	for item in items:
		# TODO: use item.name to match the crop ENUM type in player_info
		pass
	
