extends Control

#TODO: finish this

@onready var resume = $CenterContainer/VBoxContainer/Resume
@onready var main_menu = $CenterContainer/VBoxContainer/MainMenu
@onready var quit = $CenterContainer/VBoxContainer/Quit
@onready var pause_array : Array = [resume, main_menu, quit]
@onready var cursor = $Cursor
@onready var select_sound = $SelectSound
@onready var confirm_sound = $ConfirmSound
@onready var pause_sound = $PauseSound
@onready var resume_sound = $ResumeSound

var pause_index : int = 0

func _ready():
	cursor.global_position = pause_array[pause_index].global_position

func _process(_delta):
	if get_tree().paused:
		ui_manager()
		if Input.is_action_just_released("ui_accept"):
			match(pause_index):
				0:
					resume_game()
				1:
					confirm_sound.play()
				2:
					quit_game()
		elif Input.is_action_just_released("pause"):
			resume_game()

func ui_manager():
	if Input.is_action_just_released("ui_up"):
		pause_index -= 1
		select_sound.play()
	elif Input.is_action_just_released("ui_down"):
		pause_index += 1
		select_sound.play()
	if pause_index > pause_array.size() - 1:
		pause_index = 0
	elif pause_index < 0:
		pause_index = pause_array.size() - 1
	cursor.global_position = pause_array[pause_index].global_position
	cursor.global_position.x -= 20
	match(pause_index):
		0:
			cursor.size.x = 225
		1:
			cursor.size.x = 280
		2:
			cursor.size.x = 145
	cursor.size.y = pause_array[pause_index].size.y

func paused_game_toggle():
	get_tree().paused = !get_tree().paused

func resume_game():
	resume_sound.play()
	await resume_sound.finished
	paused_game_toggle()
	self.hide()

func quit_game():
	confirm_sound.play()
	await confirm_sound.finished
	get_tree().quit()
