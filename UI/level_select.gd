extends Control
#TODO: finish this. work on getting all code up to scratch
# implement animation shake for unavailable levels
# transition screen etc 
@onready var level_1 = $Level1
@onready var level_2 = $Level2
@onready var level_3 = $Level3
@onready var level_4 = $Level4
@onready var level_5 = $Level5
@onready var levels : Array = [level_1, level_2, level_3, level_4, level_5]
var current_level : int = 0
@onready var player = $PlayerIcon

func _ready():
	player.global_position = levels[current_level].global_position
	level_1.open_level()
	if GameManager.level_2_complete:
		level_2.open_level()
	if GameManager.level_3_complete:
		level_3.open_level()
	if GameManager.level_4_complete:
		level_4.open_level()
	if GameManager.level_5_complete:
		level_5.open_level()

func _input(event):
	if event.is_action_released("ui_right") and current_level < 4:
		current_level += 1
		$SelectSound.play()
	if event.is_action_released("ui_left") and current_level > 0:
		current_level -= 1
		$SelectSound.play()
	player.global_position = levels[current_level].global_position
