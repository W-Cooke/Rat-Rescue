extends Node2D

@onready var pause_screen = $CanvasLayer/PauseScreen
@onready var level_start_timer = $LevelStartTimer
@onready var level_end_timer = $LevelEndTimer
@onready var UI = $Camera2D/UI
@export var timer_left_seconds = 120
var victory : bool = false
var level_end :bool = false
signal game_start

func _ready():
	pause_screen.hide()
	level_start_timer.start()
	UI.timer_seconds = timer_left_seconds

func _process(delta):
	if Input.is_action_just_released("Pause"):
		pause_screen.pause_game()

func _on_level_start_timer_timeout():
	game_start.emit()

func _on_level_complete():
	if level_end_timer.is_stopped():
		level_end_timer.start()
		if not level_end:
			$VictorySound.play()
			level_end = true
		victory = true

func _on_level_failed():
	if level_end_timer.is_stopped():
		level_end_timer.start()
		if not level_end:
			$GameOverSound.play()
			level_end = true
		victory = false

func _on_level_end_timer_timeout():
	var path
	if victory:
		path = "res://Levels/level_02.tscn"
	else:
		path = "res://main_menu.tscn"
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file(path)


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
