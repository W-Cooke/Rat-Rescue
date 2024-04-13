extends CharacterBody2D

#region Variables
@export var SPEED : float = 300
var stored_speed = SPEED
signal rat_capture
@onready var magic_sound = $MagicSound
@onready var powerup_timer = $PowerupTimer
@onready var dash_particles = $DashParticles

# spinning script variables
@export_category ("Spin Variables")
@export var angle_threshold : float = 200.0
@export var array_size : int = 20
var current_angle : float = 0.0
var previous_angle : float = 0.0
var angle_array : Array = [0.0]
var spinning_clockwise : bool = false
var spinning_anticlockwise : bool = false
enum {CLOCKWISE, ANTICLOCKWISE, NOT}

# rotation with keyboard variables
var rotation_rate : float = 0.3
var net_rotation : float = 0.0
var keyboard_controls : bool = false

# node variables
@onready var net = $Net
@onready var netsprite = $Net/NetSprite
@onready var particles = $Net/GPUParticles2D
@onready var player_sprite = $PlayerAnimatedSprite
@onready var teleport_in_anim = $TPInAnimation
@onready var teleport_in_anim_2 = $TPInAnimation2
var casting_animation : bool = false
var controllable : bool = false
#endregion

func _ready():
	net.hide()
	dash_particles.emitting = false
	player_sprite.hide()
	teleport_in_anim.show()
	teleport_in_anim.emitting = true
	teleport_in_anim_2.show()
	if Input.get_connected_joypads().size() == 1:
		keyboard_controls = true
	

func _physics_process(_delta):
	if controllable:
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
		animation_handler()
		if velocity.x != 0:
			player_sprite.flip_h = velocity.x < 0
		move_and_slide()
		#TODO: remove and replace with settings
		if Input.is_action_just_released("controller switch"):
			if keyboard_controls:
				keyboard_controls = false
				print("mode switched to controller")
			else:
				keyboard_controls = true
				print("mode switched to keyboard controls")
		if keyboard_controls:
			net_spin_keyboard()
		else:
			controller_angle()

#region Input Handling
func controller_angle():
	# get stick vector
	var stick_rotation : Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y), Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
	# reverse x axis stick rotation so the net's angle corresponds to the angle of the analogue stick
	stick_rotation.x *= -1.0
	# conditional for deadzones
	if stick_rotation.length() > 0.3:
		current_angle = rad_to_deg(stick_rotation.angle())
		net.rotation = deg_to_rad(current_angle)
		var angle_diff = previous_angle - current_angle
		if (angle_diff >= angle_threshold) or (angle_diff <= -angle_threshold):
			# ditches angle difference if above a certain threshold (angles in godot range from 0-180 on the right side, 0- -180 on the left)
			pass
		else:
			angle_array.push_front(angle_diff)
		if angle_array.size() > array_size:
			# triggers every time the array gets pushed to a certain size, current size is defined in variable declaration
			# array size change will dictate timing of checks/gamefeel
			var mean = calculate_mean(angle_array)
			if mean < -10:
				handle_bools(CLOCKWISE)
			elif mean > 10:
				handle_bools(ANTICLOCKWISE)
			elif mean < 10 or mean > -10:
				handle_bools(NOT)
			angle_array.resize(1)
	else:
		angle_array.resize(1)
		handle_bools(NOT)
	previous_angle = current_angle

func net_spin_keyboard():
	if Input.is_action_pressed("ui_accept"):
		# rotates net and activates spell effects, emulating analogue stick controls
		net.rotation = net_rotation
		net_rotation += rotation_rate
		if net_rotation > TAU:
			net_rotation = 0.0
		handle_bools(CLOCKWISE)
	if Input.is_action_just_released("ui_accept"):
		handle_bools(NOT)

# function to handle spinning state of net
func handle_bools(state):
	match state:
		CLOCKWISE:
			spinning_anticlockwise = false
			spinning_clockwise = true
			netsprite.flip_h = false
			particles.emitting = true
			casting_animation = true
			if not magic_sound.playing:
				magic_sound.play()
		ANTICLOCKWISE:
			spinning_anticlockwise = true
			spinning_clockwise = false
			netsprite.flip_h = true
			particles.emitting = true
			casting_animation = true
			if not magic_sound.playing:
				magic_sound.play()
		NOT:
			spinning_anticlockwise = false
			spinning_clockwise = false
			particles.emitting = false
			casting_animation = false
			magic_sound.stop()

# calculates mean, who would've guessed!
func calculate_mean(arr):
	var sum = 0.0
	var count = arr.size()
	for i in arr:
		sum += i
	var mean : float = sum / count
	return mean
#endregion

func animation_handler():
	# decided which animation to play based on criteria
	# if there is any velocity, running animation will play, unless casting
	if velocity.x != 0 or velocity.y != 0:
		if not casting_animation:
			player_sprite.play("run")
		else:
			player_sprite.play("cast_loop")
	else:
		# else if there is no movement, animation is stopped unless casting
		if not casting_animation:
			player_sprite.stop()
		else:
			player_sprite.play("cast_loop")

func _on_net_body_entered(body):
	# triggers when the net collision hits a rat while spinning
	if body.is_in_group("rat"):
		if spinning_anticlockwise or spinning_clockwise:
			rat_capture.emit(body)

func _on_game_start():
	# allows for a ready state before game starts, effects play etc
	net.show()
	player_sprite.show()
	teleport_in_anim.emitting = false
	teleport_in_anim_2.hide()
	controllable = true
	particles.emitting = false
	$TPInAnimPoof.play()

func _on_go_faster_potion_picked_up():
	SPEED *= 2
	dash_particles.emitting = true
	powerup_timer.start()

func _on_powerup_timer_timeout():
	dash_particles.emitting = false
	SPEED = stored_speed
