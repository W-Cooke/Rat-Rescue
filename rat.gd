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
		#TODO: something here?
		velocity = direction * MAX_SPEED * delta
	move_and_slide()

func create_path():
	navigation_agent.target_position = target.global_position

# Either ^ or v needs something to do with the runaway logic, i feel
# probably create_path()
func _on_timer_timeout():
	create_path()


func follow_path(path):
	# TODO: write code to follow along path, set runaway bool to true at end of path
	# pseudocode:
	# The answer is RemoteTransform2D!
	# navigation_agent.target_position = path.global_positon (maybe need to specify progress ratio?)
	# assign location to progress ratio 0.0
	# iterate through progress ratio until ratio >= 1
	# turn off following and restart regular pathfinding
	# runaway = true
	pass

func path_progress():
	#TODO:
	# function for process that will update the progress ratio of the pathfollow2D
	# hopefully...
	pass

func _on_area_2d_body_entered(body):
	if body.is_in_group("rat") and runaway:
		# switches off running
		runaway = false
		# intialises list of paths
		var nearest_path = paths[0]
		# finds nearest path
		for path in paths:
			if path.global_position.distance_to(rat.global_position) < nearest_path.global_position.distance_to(rat.global_position):
				nearest_path = path
		#sends pathfollow2D to follow path function
		follow_path(nearest_path.get_child(0))
