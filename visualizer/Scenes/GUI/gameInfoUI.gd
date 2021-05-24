extends HBoxContainer

onready var TurnLabel = $GameInfo/HBoxContainer/TurnLabel/Turn

func set_player_info(num, player_info):
	match num:
		1: $Player1Info.set_player_info(player_info)
		2: $Player2Info.set_player_info(player_info)


func set_turn(turn):
	TurnLabel.set_text("Turn: %d" % turn)
