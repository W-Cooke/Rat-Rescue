extends CharacterBody2D

#region variable declaration
@export var max_speed : float = 300.0
@onready var label = $Label
@onready var timer = $Timer
@onready var player = get_tree().get_first_node_in_group("player")
enum {WANDER, RUNNING, FOLLOWING, WAITING}
var state = WANDER

@onready var rat : CharacterBody2D = $"."

const DISTANCE_THRESHOLD : float = 3.0
#region populates an array with all available rat textures
@export_category("Rat Sprites")
@export var rat_sprite_1 : CompressedTexture2D
@export var rat_sprite_2 : CompressedTexture2D
@export var rat_sprite_3 : CompressedTexture2D
@export var rat_sprite_4 : CompressedTexture2D
@export var rat_sprite_5 : CompressedTexture2D
@export var rat_sprite_6 : CompressedTexture2D
@onready var sprite_array : Array = [rat_sprite_1, rat_sprite_2, rat_sprite_3, rat_sprite_4, rat_sprite_5, rat_sprite_6]
#endregion

#region wander 
const WANDER_CIRCLE_RADIUS : int = 8
const WANDER_RANDOMNESS : float = 0.5
var wander_angle : float = 0.0
#endregion
#endregion

func _ready():
	# select a random rat texture and applies it
	$Sprite2D.texture = ImageTexture.create_from_image(sprite_array.pick_random().get_image())

func _physics_process(delta):
	match(state):
		RUNNING:
			run_from_player()
		FOLLOWING:
			follow_the_player()
		WANDER:
			wander_around()
		WAITING:
			velocity = Vector2.ZERO
	move_and_slide()

func follow_the_player():
	label.text = "Following"
	var target_global_position: Vector2 = player.global_position
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity = Steering.follow(
			velocity,
			global_position,
			target_global_position,
			max_speed
			)

func run_from_player():
	label.text = "Running!"
	var target_global_position: Vector2 = player.global_position
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity = Steering.run_away(
			velocity,
			global_position,
			target_global_position,
			max_speed
			)

func wander_around():
	label.text = "Wandering"
	var steering = wander_steering()
	velocity += steering

#TODO: replace this method with something more elegant
func random_pauses():
	#first checks if rat is not being pursued
	# then waits a moment before resuming movement
	if state = WANDER:
		state = WAITING
	# create timer in code or have it be a discrete node
	await get_tree().create_timer(randf_range(0.5, 2.0))
	if state == WAITING:
		state = WANDER

#TODO: new timer for pursuing player after a given time
func when_wandering_for_too_long():
	if state == WANDER:
		state = FOLLOWING
	await get_tree().create_timer(randf_range(1, 3))
	if state == FOLLOWING:
		state = WANDER

func wander_steering() -> Vector2:
	wander_angle = randf_range(wander_angle - WANDER_RANDOMNESS, wander_angle + WANDER_RANDOMNESS)
	var vector_to_circle : Vector2 = velocity.normalized() * max_speed
	var desired_velocity : Vector2 = vector_to_circle + Vector2(WANDER_CIRCLE_RADIUS, 0).rotated(wander_angle)
	return desired_velocity - velocity

func cast_ray() -> bool:
	# casts a ray between rat and player, if there are no obstacles between them it returns true
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if player.get_instance_id() == result["collider_id"]:
		return true
	else:
		return false

#region signals received
func _on_detection_radius_body_entered(body):
	#TODO: frequent raycasts if in area, so checks can be made if player becomes visible while still in area
	if body.is_in_group("player"):
		if cast_ray():
			state = RUNNING

func _on_detection_radius_body_exited(body):
	if body.is_in_group("player") and state == RUNNING:
		timer.start()

func _on_timer_timeout():
	print("timer finished")
	state = WANDER

func _on_player_rat_capture(body):
	if body == rat:
		print("rat caught")
		rat.remove_from_group("rat")
		$Sprite2D.hide()
		$GPUParticles2D.emitting = true
		await get_tree().create_timer(1)
		#TODO: particle effect not playing before despawning
		#TODO: add distance timer that activates following script when not detected for a while
		queue_free()
#endregion