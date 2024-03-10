extends Node2D

@onready var pause_screen = $PauseScreen

func _ready():
	pause_screen.hide()


func _process(delta):
	if Input.is_action_just_released("Pause"):
		pause_screen.pause_game()
