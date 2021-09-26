extends PopupPanel

onready var p1_name = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player1/Name
onready var p1_money = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player1/Money
onready var p2_name = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player2/Name
onready var p2_money = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player2/Money
onready var p1_crown = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player1/TextureRect/Crown
onready var p2_crown = $MarginContainer/VBoxContainer/Scoreboard/CenterContainer/ScoreContainer/Player2/TextureRect/Crown

func _ready():
	if Global.use_js:
		$MarginContainer/VBoxContainer/ExitToDesktop.visible = false


func set_player_info(num:int, player:Dictionary):	
	if num == 1:
		p1_name.text = player["name"]
		p1_money.text = "$%s" % player["money"]
	elif num == 2:
		p2_name.text = player["name"]
		p2_money.text = "$%s" % player["money"]


func update_winner():
	var gameover = Global.current_turn >= len(Global.gamelog["states"]) - 1
	var p1_win = gameover && ["WON", "TIED"].has(Global.gamelog["p1_status"])
	var p2_win = gameover && ["WON", "TIED"].has(Global.gamelog["p2_status"])
	p1_crown.visible = p1_win
	p2_crown.visible = p2_win


func _on_ExitToTitle_pressed():
	get_tree().change_scene("res://Scenes/TitleScene/TitleScene.tscn")


func _on_ExitToDesktop_pressed():
	get_tree().quit()
