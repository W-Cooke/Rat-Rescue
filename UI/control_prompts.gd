extends Control
@onready var controller = $Controller
@onready var pc = $PC

func _process(_delta):
	if GameManager.controller_used:
		controller.show()
		pc.hide()
	else:
		controller.hide()
		pc.show()
