extends CharacterBody2D

@export var MAX_SPEED = 50
@export var target : Node2D

@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D


func _physics_process(delta):
	var direction = to_local(navigation_agent.get_next_path_position())
	velocity = -direction * MAX_SPEED * delta
	move_and_slide()

func create_path():
	navigation_agent.target_position = target.global_position

func _on_timer_timeout():
	create_path()
