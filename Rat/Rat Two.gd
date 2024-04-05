extends CharacterBody2D

# this is an older version of the rat that used Godot's built in NavigationAgent for movement
# ultimately it was not as modular as I wanted, as i had to bruteforce corner escapes through pathfollow2d nodes
# rat_independence is the latest version

#region Variables
@export var MAX_SPEED : int = 300
@export var path_speed : float = 0.002
var direction : Vector2
var runaway : bool = true
var chasing_target : bool = false
var path_ratio : float = 0.0
var target_counter : int = 0

@onready var player : Node2D = get_tree().get_first_node_in_group("player")
@onready var target : Node2D = player
@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D
@onready var points : Array = get_tree().get_nodes_in_group("point")
@onready var rat : CharacterBody2D = $"."
var path_follow
#endregion

func _ready():
	print_debug(points)

func _physics_process(delta):
	if runaway:
		direction = to_local(navigation_agent.get_next_path_position())
		velocity = -direction * MAX_SPEED * delta
	else:
		direction = to_local(navigation_agent.get_next_path_position())
		velocity = direction * MAX_SPEED * delta
	move_and_slide()

func set_target():
	if runaway:
		target = player
		print("target: player")
	elif target_counter < 5 and not chasing_target:
		target = _nearest_point()
		target_counter += 1
		print("target: closest point")
		$"Running Timer".start()
		chasing_target = true
	elif not chasing_target:
		target = points[randi_range(0, points.size() - 1)]
		target_counter = 0
		chasing_target = true
		$"Running Timer".start()
		print("target: random")

func create_path():
	set_target()
	navigation_agent.target_position = target.global_position

func _on_timer_timeout():
	create_path()

func _nearest_point():
	# intialises list of points
	var nearest_point = points[0]
	# finds nearest point
	for point in points:
		if point.global_position.distance_to(rat.global_position) < nearest_point.global_position.distance_to(rat.global_position):
			nearest_point = point
	return nearest_point

#region Area2D Signals
func handle_area_entered(body):
	#TODO: work on this
	if body == rat and runaway:
		runaway = false
		path_follow = _nearest_point()
		$"Running Timer".start()

func _on_area_2d_body_entered(body):
	handle_area_entered(body)
#endregion


func _on_player_rat_capture(body):
	if body == rat:
		$Sprite2D.hide()
		$Sprite2D2.show()
		$Sprite2D2/AnimationPlayer.play()
		await $Sprite2D2/AnimationPlayer.animation_finished
		queue_free()


func _on_running_timer_timeout():
	runaway = true
	chasing_target = false
