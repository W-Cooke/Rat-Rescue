extends Control

#region variable declaration
@onready var arrow = $Arrow
@onready var music_label = $MarginContainer/VBoxContainer/HBoxContainer/MusicLabel
@onready var sfx_label = $MarginContainer/VBoxContainer/HBoxContainer2/SFXLabel
@onready var controls_label = $MarginContainer/VBoxContainer/HBoxContainer3/ControlsLabel
@onready var return_no_save = $VBoxContainer/ReturnNoSave
@onready var save_and_return = $VBoxContainer/SaveAndReturn
@onready var menu_location_array : Array = [
	music_label,
	sfx_label,
	controls_label,
	return_no_save,
	save_and_return
	]
var menu_index : int = 0
@onready var music_checkbox_yes = $MarginContainer/VBoxContainer/HBoxContainer/CheckBoxYes
@onready var sfx_checkbox_yes = $MarginContainer/VBoxContainer/HBoxContainer2/CheckBoxYes
@onready var controls_controller = $MarginContainer/VBoxContainer/HBoxContainer3/ControlsController
@onready var controls_keyboard = $MarginContainer/VBoxContainer/HBoxContainer3/ControlsKeyboard
@onready var select_audio = $SelectAudio
var controller_used : bool = true
var music_on : bool
var sfx_on : bool
#endregion

func _ready():
	controls_keyboard.hide()
	$MusicPlayer.play(3.0)
	controller_used = GameManager.controller_used
	music_on = GameManager.music_on
	sfx_on = GameManager.sfx_on
	

func _process(_delta):
	menu_controls()
	sound_manager()
	arrow.global_position = menu_location_array[menu_index].global_position
	if Input.is_action_just_released("controller switch"):
		print("game settings reset, levels reset")
		GameManager.reset_info()
	if Input.is_action_just_released("ui_accept"):
		match(menu_index):
			0:
				# music
				music_on = !music_on
			1:
				# sfx
				sfx_on = !sfx_on
			2:
				# controls
				controller_used = !controller_used
			3:
				# quit w/o saving
				revert_settings()
				return_to_main_menu()
			4:
				# save & quit
				save_settings()
				return_to_main_menu()
	if Input.is_action_just_pressed("ui_cancel"):
		revert_settings()
		return_to_main_menu()

func menu_controls():
	if Input.is_action_just_pressed("ui_down"):
		select_audio.play()
		menu_index += 1
	elif Input.is_action_just_pressed("ui_up"):
		select_audio.play()
		menu_index -= 1
	if menu_index < 0:
		menu_index = menu_location_array.size() - 1
	elif menu_index > menu_location_array.size() - 1:
		menu_index = 0
	if menu_index == 4:
		arrow.offset.x = 25
	else:
		arrow.offset.x =-45
	

func sound_manager():
	if controller_used:
		controls_keyboard.hide()
		controls_controller.show()
	else:
		controls_keyboard.show()
		controls_controller.hide()
	if music_on:
		AudioServer.set_bus_mute(2, false)
		music_checkbox_yes.show()
	else:
		AudioServer.set_bus_mute(2, true)
		music_checkbox_yes.hide()
	if sfx_on:
		AudioServer.set_bus_mute(1, false)
		sfx_checkbox_yes.show()
	else:
		AudioServer.set_bus_mute(1, true)
		sfx_checkbox_yes.hide()

func revert_settings():
	controller_used = GameManager.controller_used
	music_on = GameManager.music_on
	sfx_on = GameManager.sfx_on

func save_settings():
	GameManager.music_on = music_on
	GameManager.sfx_on = sfx_on
	GameManager.controller_used = controller_used
	GameManager.save_game()

func return_to_main_menu():
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_music_player_finished():
	$MusicPlayer.play()
