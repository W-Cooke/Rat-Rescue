extends Node

@onready var ui = $PhantomCamera2D/UI
@onready var rats_left : int = get_tree().get_nodes_in_group("rat").size()

func _ready():
	ui.victory_label.hide()

func _process(delta):
	ui.rats_left_num.text = str(rats_left)
	if rats_left < 0:
		rats_left = 0
	if rats_left == 0:
		ui.victory_label.show()

func _on_player_rat_capture(body):
	rats_left -= 1
