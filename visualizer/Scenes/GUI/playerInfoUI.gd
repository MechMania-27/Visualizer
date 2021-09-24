extends VBoxContainer
class_name InfoUI

onready var SeedInventory = $Inventory/MarginContainer/HBoxContainer/SeedInventory
onready var HarvestedInventory = $Inventory/MarginContainer/HBoxContainer/HarvestedInventory
var item_keys = Global.Item.keys()
var crop_keys = Global.CropType.keys()
const ItemBox = preload("res://Scenes/GUI/ItemBox.tscn")

var Items = {
	Global.Item.NONE : null,
	Global.Item.RAIN_TOTEM : preload("res://Assets/Inventory/Items/Rain Totem.png"),
	Global.Item.FERTILITY_IDOL : preload("res://Assets/Inventory/Items/Fertility Idol.png"),
	Global.Item.PESTICIDE : preload("res://Assets/Inventory/Items/Pesticide.png"),
	Global.Item.SCARECROW : preload("res://Assets/Inventory/Items/Scarecrow.png"),
	Global.Item.DELIVERY_DRONE : preload("res://Assets/Inventory/Items/Delivery Drone.png"),
	Global.Item.COFFEE_THERMOS : preload("res://Assets/Inventory/Items/Coffee Thermos.png"),
}

var Upgrades = {
	"NONE" : null,
	"BACKPACK" : preload("res://Assets/Inventory/Upgrades/Backpack.png"),
	"GREEN_GROCER_LOYALTY_CARD" : preload("res://Assets/Inventory/Upgrades/Green Grocer Loyalty Card.png"),
	"MOON_SHOES" : preload("res://Assets/Inventory/Upgrades/Moon Shoes.png"),
	"RABBIT'S_FOOT" : preload("res://Assets/Inventory/Upgrades/Rabbit_s Foot.png"),
	"SCYTHE" : preload("res://Assets/Inventory/Upgrades/Scythe.png"),
	"SEED-A-PULT" : preload("res://Assets/Inventory/Upgrades/Seed-a-Pult.png"),
	"SPYGLASS" : preload("res://Assets/Inventory/Upgrades/Spyglass.png"),
}

var Seeds = {
	Global.CropType.NONE : null,
	Global.CropType.CORN : preload("res://Assets/Inventory/Seed Packets/CornPacket.png"),
	Global.CropType.GRAPE : preload("res://Assets/Inventory/Seed Packets/GrapePacket.png"),
	Global.CropType.POTATO : preload("res://Assets/Inventory/Seed Packets/PotatoPacket.png"),
	Global.CropType.JOGAN_FRUIT : preload("res://Assets/Inventory/Seed Packets/JoganPacket.png"),
	Global.CropType.DUCHAM_FRUIT : preload("res://Assets/Inventory/Seed Packets/DuchamPacket.png"),
	Global.CropType.PEANUT : preload("res://Assets/Inventory/Seed Packets/PeanutPacket.png"),
	Global.CropType.QUADROTRITICALE : preload("res://Assets/Inventory/Seed Packets/WheatPacket.png"),
	Global.CropType.GOLDEN_CORN : preload("res://Assets/Inventory/Seed Packets/GoldenPacket.png")
}

var Harvests = {
	Global.CropType.NONE : null,
	Global.CropType.CORN : preload("res://Assets/Inventory/Harvested Crops/CornHarvested.png"),
	Global.CropType.GRAPE : preload("res://Assets/Inventory/Harvested Crops/GrapeHarvested.png"),
	Global.CropType.POTATO : preload("res://Assets/Inventory/Harvested Crops/PotatoHarvested.png"),
	Global.CropType.JOGAN_FRUIT : preload("res://Assets/Inventory/Harvested Crops/JoganHarvested.png"),
	Global.CropType.DUCHAM_FRUIT : preload("res://Assets/Inventory/Harvested Crops/DuchamHarvested.png"),
	Global.CropType.PEANUT : preload("res://Assets/Inventory/Harvested Crops/PeanutHarvested.png"),
	Global.CropType.QUADROTRITICALE : preload("res://Assets/Inventory/Harvested Crops/WheatHarvested.png"),
	Global.CropType.GOLDEN_CORN : preload("res://Assets/Inventory/Harvested Crops/GoldenHarvested.png")
}

func _ready():
	for crop in crop_keys:
		if Global.CropType.get(crop) == Global.CropType.NONE: continue
		
		var seedSlot = ItemBox.instance()
		seedSlot.name = crop
		
		var harvestedSlot = ItemBox.instance()
		harvestedSlot.name = crop
		
		SeedInventory.add_child(seedSlot, true)
		HarvestedInventory.add_child(harvestedSlot, true)
		
		# Set textures of inventory slot
		seedSlot.set_texture(Seeds.get(Global.CropType.get(crop)))
		harvestedSlot.set_texture(Harvests.get(Global.CropType.get(crop)))
		
	


func set_player_info(player_info):
	# Fill in Player Name text
	$NameContainer/Name.set_text(player_info["name"])
	
	# Fill in Player Money text
	$MoneyContainer/Money.set_text("$ %d" % player_info["money"])
	
	# Fill in Player Item sprite
	$AttributeContainer/Item.texture = Items.get(Global.Item.get(player_info["item"]))
	# Fill in Player Upgrade sprite
	$AttributeContainer/Upgrade.texture = Upgrades.get(player_info["upgrade"])
	
	# Fill in Player Inventory boxes
	for item in SeedInventory.get_children():
		if player_info["seedInventory"].keys().has(item.name):
			item.set_text(String(player_info["seedInventory"][item.name]))
	
	for item in HarvestedInventory.get_children():
		if player_info["harvestedInventoryTotals"].keys().has(item.name):
			item.set_text(String(player_info["harvestedInventoryTotals"][item.name]))
		
	
