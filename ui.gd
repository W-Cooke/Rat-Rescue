extends Control

#TODO: UI STUFF
@onready var rats : Array = get_tree().get_nodes_in_group("rat")
@onready var number_of_rats = rats.size()
@onready var rats_left_num = $VBoxContainer/HBoxContainer/RatsLeftNum
@onready var victory_label = $VBoxContainer/VictoryLabel
