extends Control

@onready var story_label = $StoryLabel
@onready var text_boop = $TextAudio
@onready var boop_timer = $TextAudio/Timer
@onready var text_end_timer = $TextEndTimer
var frame_buffer : int = 0
var frame_limit : int = 3
var text_progressing : bool 

func _ready():
	story_label.visible_characters = 0
	text_progressing = true

func _process(_delta):
	frame_buffer += 1
	if text_progressing:
		if boop_timer.is_stopped():
			boop_timer.start()
	else:
		boop_timer.stop()
	if frame_buffer % frame_limit == 0:
		if story_label.get_visible_ratio() < 1:
			story_label.visible_characters += 1
		else:
			text_progressing = false
			boop_timer.stop()
			if text_end_timer.is_stopped():
				text_end_timer.start()
		frame_buffer = 0
	if Input.is_action_just_released("ui_accept"):
		_on_text_end_timer_timeout()


func _on_timer_timeout():
	text_boop.play()


func _on_text_end_timer_timeout():
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://main_menu.tscn")
