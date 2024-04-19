extends CanvasLayer

#TODO: UI STUFF
@onready var rats : Array = get_tree().get_nodes_in_group("rat")
@onready var number_of_rats = rats.size()
@onready var player = get_tree().get_first_node_in_group("player")
@onready var rats_left_num = $VBoxContainer/HBoxContainer/RatsLeftNum
@onready var center_screen_label = $CenterScreeenLabel
@onready var controller_icon = $MarginContainer/Controller
@onready var keyboard_icon = $MarginContainer/Keyboard
@onready var game_timer = $MarginContainer2/GameTimer
@onready var rats_left_container = $VBoxContainer
@onready var controls_container = $MarginContainer
var game_playing : bool = false
var frames : int = 1
var timer_seconds : int = 1
var timer_minutes : int = 0
signal level_complete
signal level_failed

func _ready():
	center_screen_label.text = "GET READY"
	game_timer.hide()
	rats_left_container.hide()
	controls_container.hide()

func _process(_delta):
	if game_playing:
		frames += 1
	if frames % 60 == 0:
		timer_seconds -= 1
		frames = 0
		game_timer.text = "Time: " + str(timer_seconds)
	if player.keyboard_controls:
		controller_icon.hide()
		keyboard_icon.show()
	else:
		controller_icon.show()
		keyboard_icon.hide()
	rats_left_num.text = str(number_of_rats)
	if number_of_rats <= 0:
		center_screen_label.show()
		center_screen_label.text = "RATS RESCUED!"
		$VBoxContainer/HBoxContainer/RatsLeftLabel.hide()
		rats_left_num.hide()
		level_complete.emit()
		game_timer.hide()
	elif timer_seconds <= 0:
		game_timer.hide()
		game_playing = false
		center_screen_label.text = "FAILURE"
		center_screen_label.show()
		level_failed.emit()

func _on_signal_bus_rat_caught():
	number_of_rats -= 1

func _on_start_timer_timeout():
	center_screen_label.hide()
	game_playing = true
	game_timer.show()
	game_timer.text = "Time: " + str(timer_seconds)
	rats_left_container.show()
	controls_container.show()

