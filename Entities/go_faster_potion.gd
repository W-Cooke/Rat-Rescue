extends Node2D

signal picked_up
@onready var sprite = $GoFasterPotion
@onready var poof = $PoofParticles
@onready var timer = $Timer
@onready var player = get_tree().get_first_node_in_group("player")


func _on_area_2d_body_entered(body):
	if body == player:
		picked_up.emit()
		sprite.hide()
		poof.emitting = true
		timer.start()


func _on_timer_timeout():
	queue_free()
