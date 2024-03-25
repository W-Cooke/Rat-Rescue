extends CanvasLayer

# Code for transition screen, it makes changing scenes smoother and less jarring

signal on_transition_finished

@onready var color_rect = $NetTransitionScreen
@onready var animation_player = $AnimationPlayer
@onready var fade_in_sound = $FadeInSound
@onready var fade_out_sound = $FadeOutSound

func _ready():
	# as an autoload, this scene will always be available so it needs to be hidden
	color_rect.hide()
	animation_player.animation_finished.connect(_on_animation_finished)

func transition():
	# plays the first animation, fading to black
	color_rect.show()
	fade_in_sound.play()
	# animation player will emit a signal onces finished
	animation_player.play("FadeToBlack")

func _on_animation_finished(anim_name):
	if anim_name == "FadeToBlack":
		fade_out_sound.play()
		animation_player.play("FadeFromBlack")
		on_transition_finished.emit()
	elif anim_name == "FadeFromBlack":
		color_rect.hide()