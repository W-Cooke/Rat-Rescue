extends CharacterBody2D

@export var MAX_SPEED = 50
@export var target : Node2D
var direction : Vector2
var runaway = true
var path_ratio : float = 0.0
var path_speed : float = 200

@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D
@onready var paths = get_tree().get_nodes_in_group("path")
@onready var rat = $"."

func _physics_process(delta):
	if runaway:
		direction = to_local(navigation_agent.get_next_path_position())
		velocity = -direction * MAX_SPEED * delta
	else:
		# TODO: add something here?
		velocity = direction * MAX_SPEED * delta
	move_and_slide()

func create_path():
	navigation_agent.target_position = target.global_position

func _on_timer_timeout():
	if runaway:
		create_path()

func follow_path(path):
	# TODO: write code to follow along path, set runaway bool to true at end of path
	# pseudocode:
	# assign location to progress ratio 0.0
	# iterate through progress ratio until ratio >= 1
	# turn off following and restart regular pathfinding
	# runaway = true
	pass

func _on_area_2d_body_entered(body):
	if body.is_in_group("rat") and runaway:
		runaway = false
		var nearest_path = paths[0]
		for path in paths:
			if path.global_position.distance_to(rat.global_position) < nearest_path.global_position.distance_to(rat.global_position):
				nearest_path = path
		print_debug(nearest_path)
		follow_path(nearest_path)
