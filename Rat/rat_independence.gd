extends CharacterBody2D

#region variable declaration
@export var maximum_speed : float = 300.0
var max_speed = maximum_speed
@onready var label = $Label
@onready var timer = $Timer
@onready var distance_timer = $DistanceTimer
@onready var wandering_timer = $WanderingTimer
@onready var follow_timer = $WanderingTimer/FollowTimer
@onready var wait_timer = $WaitTimer
@onready var raycast_timer = $RaycastTimer
@onready var player = get_tree().get_first_node_in_group("player")
enum {WANDER, RUNNING, FOLLOWING, WAITING, DASH}
var state = WANDER

#region sound
@onready var capture_sound = $CaptureSound
@onready var detected_sound = $DetectedSound
@onready var scratch_sound = $ScratchSound
#endregion

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
const WANDER_RANDOMNESS : float = 1.0
var wander_angle : float = 0.0
#endregion
#endregion

func _ready():
	# select a random rat texture and applies it
	var image = ImageTexture.create_from_image(sprite_array.pick_random().get_image())
	#TODO: set image to texture of dash particle as well
	$Sprite2D.texture = image

func _physics_process(_delta):
	# state machine 
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

#region state methods

func follow_the_player():
	label.text = "FOLLOW"
	var target_global_position: Vector2 = player.global_position
	velocity = Steering.follow(
		velocity,
		global_position,
		target_global_position,
		max_speed
		)

func run_from_player():
	label.text = "RUN"
	var target_global_position: Vector2 = player.global_position
	velocity = Steering.run_away(
		velocity,
		global_position,
		target_global_position,
		max_speed
	)

func wander_around():
	label.text = "WANDER"
	var steering = wander_steering()
	velocity += steering

#TODO: replace this method with something more elegant
func random_pauses():
	label.text = "PAUSE"
	if state == WANDER:
		state = WAITING
		scratch_sound.play()
		wait_timer.start(randf_range(0.4, 1.5))

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
#endregion

#region signals received
func _on_detection_radius_body_entered(body):
	if body.is_in_group("player"):
		raycast_timer.start()
		if cast_ray():
			state = RUNNING
			detected_sound.play()

func _on_detection_radius_body_exited(body):
	if body.is_in_group("player") and state == RUNNING:
		timer.start()

func _on_timer_timeout():
	state = WANDER
	wandering_timer.start()

func _on_player_rat_capture(body):
	if body == self:
		self.remove_from_group("rat")
		$GPUParticles2D.emitting = true
		$Sprite2D.hide()
		label.hide()
		capture_sound.play()
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_distance_timer_timeout():
	random_pauses()
	distance_timer.start(randf_range(3.0, 6.0))

func _on_wait_timer_timeout():
	if state == WAITING:
		scratch_sound.stop()
		state = WANDER

func _on_raycast_timer_timeout():
	if cast_ray():
		raycast_timer.stop()
		if state != RUNNING:
			detected_sound.play()
			state = RUNNING

func _on_wandering_timer_timeout():
	state = FOLLOWING
	follow_timer.start(randf_range(1.0, 2.0))

func _on_follow_timer_timeout():
	if state != WANDER:
		state = WANDER
#endregion
