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
@onready var title_label = $TitleLabel
var move_tween : Tween

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

func _process(_delta):
	match(current_level):
		0:
			title_label.text = "Castle Dungeon"
		1:
			title_label.text = "Courtyard"
		2:
			title_label.text = "Castle Town"
		3:
			title_label.text = "Moatside Settlement"
		4:
			title_label.text = "Royal Palace"

func _input(event):
	if move_tween and move_tween.is_running():
		return
	if event.is_action_released("ui_right") and current_level < 4:
		current_level += 1
		$SelectSound.play()
		tween_player()
	if event.is_action_released("ui_left") and current_level > 0:
		current_level -= 1
		$SelectSound.play()
		tween_player()
	if event.is_action_released("ui_accept"):
		if levels[current_level].playable:
			$ConfirmSound.play()
			var level = current_level + 1
			var path = "res://Levels/level_0%s.tscn" % level
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().change_scene_to_file(path)
		else:
			levels[current_level].shake()
			$ErrorSound.play()
	if event.is_action_released("ui_cancel"):
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file("res://main_menu.tscn")

func tween_player():
	move_tween = get_tree().create_tween()
	move_tween.tween_property(player, "global_position", levels[current_level].global_position, 0.2).set_trans(Tween.TRANS_SINE)

func _on_music_finished():
	$music.play()
