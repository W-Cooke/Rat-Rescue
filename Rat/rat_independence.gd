extends CharacterBody2D

#region variable declaration
@export var maximum_speed : float = 300.0
var wander_speed : float = maximum_speed / 2
var max_speed : float = maximum_speed
@onready var label = $Label
@onready var timer = $Timers/Timer
@onready var distance_timer = $Timers/DistanceTimer
@onready var wandering_timer = $Timers/WanderingTimer
@onready var follow_timer = $Timers/WanderingTimer/FollowTimer
@onready var wait_timer = $Timers/WaitTimer
@onready var raycast_timer = $Timers/RaycastTimer
@onready var dash_timer = $Timers/DashTimer
@onready var dash_cooldown_timer = $Timers/DashCooldownTimer
@onready var player = get_tree().get_first_node_in_group("player")
enum {WANDER, RUNNING, FOLLOWING, WAITING, DASH, CAUGHT}
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
@onready var dash_particles : GPUParticles2D = $DashParticles
@onready var spell_effect : AnimatedSprite2D = $SpellEffect
#endregion

#region position array
var position_array : Array = []
var array_max_size : int = 20
var dash_cooldown : bool = true
#endregion

#region default directions
var dir_NE : Vector2 = Vector2(1.0, 1.0)
var dir_NW : Vector2 = Vector2(-1.0, 1.0)
var dir_SE : Vector2 = Vector2(1.0, -1.0)
var dir_SW : Vector2 = Vector2(-1.0, -1.0)
#endregion

#region raycasts
@onready var RC_N : Object = $RayCastNorth
@onready var RC_S : Object = $RayCastSouth
@onready var RC_E : Object = $RayCastEast
@onready var RC_W : Object = $RayCastWest

@onready var raycast_NE : Array[Object] = [RC_N, RC_E]
@onready var raycast_NW : Array[Object] = [RC_N, RC_W]
@onready var raycast_SE : Array[Object] = [RC_S, RC_E]
@onready var raycast_SW : Array[Object] = [RC_S, RC_W]
#endregion

#region wander 
const WANDER_CIRCLE_RADIUS : int = 8
const WANDER_RANDOMNESS : float = 1.0
var wander_angle : float = 0.0
#endregion

#region signals
signal rat_caught
#endregion
#endregion

func _ready():
	# select a random rat texture and applies it to rat and dash effect
	var image = ImageTexture.create_from_image(sprite_array.pick_random().get_image())
	dash_particles.texture = image
	$Sprite2D.texture = image
	spell_effect.hide()
	# randomise speed a little
	maximum_speed = randf_range(maximum_speed - 10, maximum_speed + 40.0)

func _physics_process(_delta):
	# state machine 
	match(state):
		RUNNING:
			run_from_player()
			if check_for_no_movement():
				velocity = decide_corner_direction()
				state = DASH
		FOLLOWING:
			follow_the_player()
		WANDER:
			wander_around()
		DASH:
			dash()
		WAITING:
			velocity = Vector2.ZERO
		CAUGHT:
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

func random_pauses():
	if state == WANDER:
		label.text = "PAUSE"
		state = WAITING
		scratch_sound.play()
		wait_timer.start(randf_range(0.4, 1.5))

func wander_steering() -> Vector2:
	# adds random vector to current velocity, allowing for random movement completely in code
	wander_angle = randf_range(wander_angle - WANDER_RANDOMNESS, wander_angle + WANDER_RANDOMNESS)
	var vector_to_circle : Vector2 = velocity.normalized() * wander_speed
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

func dash():
	# Nyoooom!
	if dash_cooldown:
		max_speed *= 3
		velocity *= max_speed
		dash_timer.start()
		dash_particles.emitting = true
		self.set_collision_layer_value(1, false)
		self.set_collision_mask_value(2, false)
		dash_cooldown_timer.start()
		dash_cooldown = false
		label.text = "DASH"
#endregion

#region Dash Logic
func check_for_no_movement() -> bool:
	# saves an array of recent positions, activates if all the elements in the array are the same value
	# indicating that the rat hasn't moved, i.e. is stuck
	position_array.push_front(Vector2(snappedf(self.global_position.x, 1.0), snappedf(self.global_position.y, 1.0)))
	if position_array.size() == array_max_size:
		if position_array.count(Vector2(snappedf(self.global_position.x, 1.0), snappedf(self.global_position.y, 1.0))) >= array_max_size:
			position_array.clear()
			return true
		else:
			position_array.clear()
	return false

func randomise_angles():
	# calculates a random direction out of the 90 degree range available to escape a corner
	dir_NE = Vector2(randf_range(0.0, 1.0), randf_range(-1.0, 0.0))
	dir_NW = Vector2(randf_range(-1.0, 0.0), randf_range(-1.0, 0.0))
	dir_SE = Vector2(randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	dir_SW = Vector2(randf_range(-1.0, 0.0), randf_range(0.0, 1.0))

func decide_corner_direction() -> Vector2:
	randomise_angles()
	if raycast_NE[0].is_colliding() and raycast_NE[1].is_colliding():
		return dir_SW
	elif raycast_NW[0].is_colliding() and raycast_NW[1].is_colliding():
		return dir_SE
	elif raycast_SE[0].is_colliding() and raycast_SE[1].is_colliding():
		return dir_NW
	elif raycast_SW[0].is_colliding() and raycast_SW[1].is_colliding():
		return dir_NE
	else:
		return Vector2.ZERO

#endregion

#region signals received
func _on_detection_radius_body_entered(body):
	# Detection logic, activated when player is in proximity
	if body.is_in_group("player"):
		raycast_timer.start()
		if not timer.is_stopped():
			timer.stop()
		# casts ray to player, if there are no obstacles, then the player is in sight
		if cast_ray():
			if state != RUNNING and state != DASH:
				state = RUNNING
				detected_sound.play()


func _on_detection_radius_body_exited(body):
	# starts timer for returning to wander state, ensures the rat runs away before reverting
	if body.is_in_group("player") and state == RUNNING:
		timer.start()

func _on_timer_timeout():
	# restarts running timer if still in criteria, else rat returns to wandering
	#TODO: check the added state == DASH works as intended
	if state == RUNNING or state == DASH:
		state = WANDER
		wandering_timer.start()
	else:
		timer.start()

func _on_player_rat_capture(body):
	# checks to see if the body caught by the net is the body of the rat
	# executes logic to show capture effects, affect score, and remove rat
	if body == self:
		self.remove_from_group("rat")
		state = CAUGHT
		rat_caught.emit()
		$Sprite2D.hide()
		spell_effect.show()
		spell_effect.play()
		label.hide()
		capture_sound.play()
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_distance_timer_timeout():
	# executes random pauses when wandering, for more naturalistic motion
	if state == WANDER:
		random_pauses()
	distance_timer.start(randf_range(3.0, 6.0))

func _on_wait_timer_timeout():
	# returns to wandering
	if state == WAITING:
		scratch_sound.stop()
		state = WANDER

func _on_raycast_timer_timeout():
	# set to go off at frequent intervals
	if cast_ray():
		raycast_timer.stop()
		if state != RUNNING:
			detected_sound.play()
			state = RUNNING

func _on_wandering_timer_timeout():
	# set to move towards player every now and then
	if state != RUNNING:
		state = FOLLOWING
		follow_timer.start(randf_range(1.0, 2.0))
	

func _on_follow_timer_timeout():
	# TODO: finish notations
	if state != WANDER or state != RUNNING:
		state = WANDER

func _on_dash_timer_timeout():
	state = RUNNING
	max_speed = maximum_speed
	dash_particles.emitting = false
	self.set_collision_layer_value(1, true)
	self.set_collision_mask_value(2, true)

func _on_dash_cooldown_timer_timeout():
	dash_cooldown = true
#endregion
