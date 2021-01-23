extends Node

# Control PhaseLabel appearance
export var use_phase_label: bool = false

onready var Player1Info: Node = $Player1Info
onready var Player2Info: Node = $Player2Info
onready var TurnLabel: Label = $TurnInfo/VBoxContainer/TurnLabel
onready var PhaseLabel: Label = $TurnInfo/VBoxContainer/PhaseLabel


func _ready():
	PhaseLabel.set_visible(use_phase_label)
	
	Player1Info.set_name("Player 1")
	Player2Info.set_name("Player 2")
	set_turn(0)


func set_turn(turn: int):
	TurnLabel.set_text("Turn: %d" % turn)


func set_phase(phase: String):
	PhaseLabel.set_text("Phase: %s" % phase)
