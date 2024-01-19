extends CharacterBody2D

#region Variables
@export var MAX_SPEED : int = 300
@export var path_speed : float = 0.006
var direction : Vector2
var runaway : bool = true
var following_path : bool = false
var path_ratio : float = 0.0

@onready var player : Node2D = get_tree().get_first_node_in_group("player")
@onready var target : Node2D = player
@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D
@onready var paths : Array = get_tree().get_nodes_in_group("path")
@onready var rat : CharacterBody2D = $"."
var path_follow
#endregion

func _ready():
	print(paths)

func _physics_process(delta):
	if runaway:
		direction = to_local(navigation_agent.get_next_path_position())
		velocity = -direction * MAX_SPEED * delta
	else:
		direction = to_local(navigation_agent.get_next_path_position())
		velocity = direction * MAX_SPEED * delta
	move_and_slide()
	progress_ratio()
	print_debug("runaway: " + str(runaway))
	print_debug("following_path: " + str(following_path))
	print_debug("target: " + str(target))

func progress_ratio():
	if not runaway:
		if path_ratio < 1:
			path_follow.progress_ratio = path_ratio
			path_ratio += path_speed
			if path_ratio >= 1:
				runaway = true
				following_path = false
				path_follow.progress_ratio -= 1
				path_ratio = 0.0
	else:
		if path_follow:
			path_follow.progress_ratio = 0.0

func set_target():
	if runaway:
		target = player
	elif not following_path:
		target = _nearest_path().get_child(0).get_child(0)
		following_path = true

func create_path():
	set_target()
	navigation_agent.target_position = target.global_position

func _on_timer_timeout():
	create_path()

func _nearest_path():
	# intialises list of paths
	var nearest_path = paths[0]
	# finds nearest path
	for path in paths:
		if path.get_child(0).get_child(0).global_position.distance_to(rat.global_position) < nearest_path.get_child(0).get_child(0).global_position.distance_to(rat.global_position):
			nearest_path = path
	return nearest_path

#region Area2D Signals
func handle_area_entered(body):
	if body.is_in_group("rat") and runaway:
		runaway = false
		path_follow = _nearest_path().get_child(0)
		path_follow.progress_ratio = 0.0

func _on_area_2d_body_entered(body):
	handle_area_entered(body)

func _on_area_2d_2_body_entered(body):
	handle_area_entered(body)

func _on_area_2d_3_body_entered(body):
	handle_area_entered(body)

func _on_area_2d_4_body_entered(body):
	handle_area_entered(body)
#endregion
