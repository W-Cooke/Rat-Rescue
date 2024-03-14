extends Control

@onready var startgame_label = $CenterContainer/VBoxContainer/StartGame
@onready var settings_label = $CenterContainer/VBoxContainer/Settings
@onready var credits_label = $CenterContainer/VBoxContainer/Credits
@onready var quit_label = $CenterContainer/VBoxContainer/Quit
@onready var menu_array : Array = [startgame_label, settings_label, credits_label, quit_label]
enum {START, SETTINGS, CREDITS, QUIT}
@onready var main_menu = $CenterContainer
@onready var cursor = $Cursor
@onready var test_level = "res://test_scene.tscn"
@onready var confirm_sound = $ConfirmSound
@onready var select_sound = $SelectSound


#region level select
var level_select : bool = false
@onready var level_selector = $LevelSelector
@onready var level_cursor = $LevelCursor
@onready var level_select_num = $LevelSelector/HBoxContainer/LevelSelectNum
var level_index : int = 1
#endregion

var cursor_index : int = 0

func _ready():
	cursor.global_position = menu_array[cursor_index].global_position

func _process(delta):
	ui_manager()
	move_to_scene()

func move_to_scene():
	if Input.is_action_just_pressed("ui_accept"):
		confirm_sound.play()
		await confirm_sound.finished
		if not level_select:
			match(cursor_index):
				0:
					print("START GAME")
					main_menu.hide()
					level_selector.show()
					cursor.hide()
					level_cursor.show()
					level_select = true
				1:
					print("SETTING")
				2:
					print("CREDITS")
				3:
					print("QUIT")
					get_tree().quit()
		else:
			var path = "res://Levels/level_0%s.tscn" % level_index
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().change_scene_to_file(path)
	if Input.is_action_just_pressed("Pause") and level_select:
				main_menu.show()
				level_selector.hide()
				cursor.show()
				level_cursor.hide()
				select_sound.play()
				level_select = false

func ui_manager():
	if not level_select:
		if Input.is_action_just_released("ui_up"):
			cursor_index -= 1
			select_sound.play()
		if Input.is_action_just_released("ui_down"):
			cursor_index += 1
			select_sound.play()
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
	else:
		if Input.is_action_just_pressed("ui_right"):
			select_sound.play()
			level_index += 1
		if Input.is_action_just_pressed("ui_left"):
			select_sound.play()
			level_index -= 1
		if level_index > 5:
			level_index = 1
		elif level_index < 1:
			level_index = 5
		level_select_num.text = "0" + str(level_index)


func _on_menu_music_finished():
	$MenuMusic.play()
