extends Node2D

@onready var logo = $PbLogo
@onready var message = $Controller1
@onready var entry_timer = $EntryTimer
@onready var logo_timer = $LogoTimer
@onready var message_timer = $MessageTimer
@onready var anim = $CanvasLayer/AnimationPlayer

# this simple script cycles through beginning messages before entering the main menu
# The player can, at any time, press confirm to be taken to the main menu immediately

func _ready():
	logo.hide()
	message.hide()
	anim.play("Fade-Out")

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("Pause"):
		move_forward()

func _on_entry_timer_timeout():
	anim.play("Fade_In")
	logo.show()
	await anim.animation_finished
	logo_timer.start()

func _on_logo_timer_timeout():
	anim.play("Fade-Out")
	await anim.animation_finished
	logo.hide()
	message.show()
	anim.play("Fade_In")
	await anim.animation_finished
	message_timer.start()


func _on_message_timer_timeout():
	anim.play("Fade-Out")
	await anim.animation_finished
	message.hide()
	$CanvasLayer.hide()
	await get_tree().create_timer(1.0)
	move_forward()

func move_forward():
	$CanvasLayer.hide()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://main_menu.tscn")
