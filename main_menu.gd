extends Control

@onready var startgame_label = $CenterContainer/VBoxContainer/StartGame
@onready var settings_label = $CenterContainer/VBoxContainer/Settings
@onready var credits_label = $CenterContainer/VBoxContainer/Credits
@onready var quit_label = $CenterContainer/VBoxContainer/Quit
@onready var menu_array : Array = [startgame_label, settings_label, credits_label, quit_label]
enum {START, SETTINGS, CREDITS, QUIT}
@onready var cursor = $Cursor

var cursor_index : int = 0

func _ready():
	cursor.global_position = menu_array[cursor_index].global_position

func _process(delta):
	ui_manager()
	move_to_scene()

func move_to_scene():
	if Input.is_action_just_pressed("ui_accept"):
		$ConfirmSound.play()
		match(cursor_index):
			0:
				print("START GAME")
			1:
				print("SETTING")
			2:
				print("CREDITS")
			3:
				print("QUIT")
				await $ConfirmSound.finished
				get_tree().quit()

func ui_manager():
	if Input.is_action_just_released("ui_up"):
		cursor_index -= 1
		$SelectSound.play()
	if Input.is_action_just_released("ui_down"):
		cursor_index += 1
		$SelectSound.play()
	if cursor_index > (menu_array.size() - 1):
		cursor_index = 0
	elif cursor_index < 0:
		cursor_index = menu_array.size() - 1
	cursor.global_position = menu_array[cursor_index].global_position
	cursor.size.x = menu_array[cursor_index].text.length() * 33
	cursor.size.y = menu_array[cursor_index].size.y
	# this is so hacky but IDK how to center this bloody variable cursor
	match(cursor_index):
		0:
			cursor.position.x -= menu_array[cursor_index].text.length() * 2
		1:
			cursor.position.x += menu_array[cursor_index].text.length() * 2
		2:
			cursor.position.x += menu_array[cursor_index].text.length() * 4
		3:
			cursor.position.x += menu_array[cursor_index].text.length() * 20
