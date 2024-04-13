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
var controller_controls : bool = true
var music_is_muted : bool
var sfx_is_muted : bool
#endregion

func _ready():
	pass
	#PSEUDOCODE:
	#TODO:
	# load from resource
	# set bools from loaded resource
	# set sprites to show based off settings

func _process(_delta):
	menu_controls()
	arrow.global_position = menu_location_array[menu_index].global_position
	if Input.is_action_just_released("ui_accept"):
		match(menu_index):
			0:
				# music
				if AudioServer.is_bus_mute(2):
					AudioServer.set_bus_mute(2, false)
					music_checkbox_yes.show()
				else:
					AudioServer.set_bus_mute(2, true)
					music_checkbox_yes.hide()
			1:
				# sfx
				if AudioServer.is_bus_mute(1):
					AudioServer.set_bus_mute(1, false)
					sfx_checkbox_yes.show()
				else:
					AudioServer.set_bus_mute(1, true)
					sfx_checkbox_yes.hide()
				pass
			2:
				# controls
				controller_controls = !controller_controls
				if controller_controls:
					controls_keyboard.hide()
					controls_controller.show()
				else:
					controls_keyboard.show()
					controls_controller.hide()
				pass
			3:
				# quit w/o saving
				#TODO: revert to settings before initialising
				TransitionScreen.transition()
				await TransitionScreen.on_transition_finished
				get_tree().change_scene_to_file("res://main_menu.tscn")
			4:
				# save & quit
				pass

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


func _on_music_player_finished():
	$MusicPlayer.play()
