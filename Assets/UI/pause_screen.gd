extends Control

#TODO: finish this

@onready var resume = $CenterContainer/VBoxContainer/Resume
@onready var main_menu = $CenterContainer/VBoxContainer/MainMenu
@onready var quit = $CenterContainer/VBoxContainer/Quit
@onready var pause_array : Array = [resume, main_menu, quit]
@onready var cursor = $Cursor
@onready var select_sound = $SelectSound

var pause_index : int = 0

func _ready():
	cursor.global_position = pause_array[pause_index].global_position

func _process(_delta):
	ui_manager()

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
	cursor.size.x = pause_array[pause_index].text.length() * 33
	cursor.size.y = pause_array[pause_index].size.y
