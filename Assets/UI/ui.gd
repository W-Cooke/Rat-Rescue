extends Control

#TODO: UI STUFF
@onready var rats : Array = get_tree().get_nodes_in_group("rat")
@onready var number_of_rats = rats.size()
@onready var rats_left_num = $VBoxContainer/HBoxContainer/RatsLeftNum
@onready var victory_label = $VBoxContainer/VictoryLabel
@onready var controller_icon = $MarginContainer/Controller
@onready var keyboard_icon = $MarginContainer/Keyboard

func _ready():
	rats_left_num = number_of_rats
