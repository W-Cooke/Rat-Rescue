extends Node2D

@onready var pause_screen = $PauseScreen
signal game_start
func _ready():
	pause_screen.hide()


func _process(delta):
	if Input.is_action_just_released("Pause"):
		pause_screen.pause_game()


func _on_level_start_timer_timeout():
	game_start.emit()
