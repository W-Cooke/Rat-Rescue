extends Control

#TODO: UI STUFF
@onready var rats : Array = get_tree().get_nodes_in_group("rat")
@onready var number_of_rats = rats.size()
@onready var player = get_tree().get_first_node_in_group("player")
@onready var rats_left_num = $VBoxContainer/HBoxContainer/RatsLeftNum
@onready var victory_label = $VictoryLabel
@onready var controller_icon = $MarginContainer/Controller
@onready var keyboard_icon = $MarginContainer/Keyboard

func _ready():
	$".".size = get_viewport().get_visible_rect().size

func _process(_delta):
	if player.keyboard_controls:
		controller_icon.hide()
		keyboard_icon.show()
	else:
		controller_icon.show()
		keyboard_icon.hide()
	rats_left_num.text = str(number_of_rats)
	if number_of_rats <= 0:
		victory_label.show()
		$VBoxContainer/HBoxContainer/RatsLeftLabel.hide()
		rats_left_num.hide()


func _on_signal_bus_rat_caught():
	number_of_rats -= 1
