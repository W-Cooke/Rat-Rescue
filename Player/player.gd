extends CharacterBody2D

#region Variables
@export var SPEED : float = 75.00
signal net_spin
signal rat_capture
@onready var magic_sound = $MagicSound
@onready var spell_effect = $SpellEffect

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
#TODO: tidy up
var rotation_rate : float = 0.3
var net_rotation : float = 0.0
var keyboard_controls : bool = false

# node variables
@onready var net = $Net
@onready var netsprite = $Net/NetSprite
@onready var particles = $Net/GPUParticles2D
@onready var player_sprite = $PlayerAnimatedSprite
var anim_warmup : bool = false
var anim_done : bool = false
var anim_looping : bool = false
#endregion

func _ready():
	spell_effect.hide()

func _physics_process(_delta):
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
	animation_handler()
	if velocity.x != 0:
		player_sprite.flip_h = velocity.x < 0
	move_and_slide()
	#TODO: remove and replace with settings
	if Input.is_action_just_released("controller switch"):
		if keyboard_controls:
			keyboard_controls = false
			print("mode switched to keyboard controls")
		else:
			keyboard_controls = true
			print("mode switched to controller")
	if keyboard_controls:
		net_spin_keyboard()
	else:
		controller_angle()
	#TODO: check if this works

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
		net.rotation = net_rotation
		net_rotation += rotation_rate
		if net_rotation > TAU:
			net_rotation = 0.0
		#TODO: check if conditional in process has fixed this!
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
			spell_effect.flip_h = true
			spell_effect.show()
			particles.emitting = true
			if not magic_sound.playing:
				magic_sound.play()
		ANTICLOCKWISE:
			spinning_anticlockwise = true
			spinning_clockwise = false
			netsprite.flip_h = true
			spell_effect.flip_h = false
			spell_effect.show()
			particles.emitting = true
			if not magic_sound.playing:
				magic_sound.play()
		NOT:
			spinning_anticlockwise = false
			spinning_clockwise = false
			particles.emitting = false
			spell_effect.hide()
			magic_sound.stop()
			anim_looping = false
			anim_warmup = false
			anim_done = false

# calculates mean, who would've guessed!
func calculate_mean(arr):
	var sum = 0.0
	var count = arr.size()
	for i in arr:
		sum += i
	var mean : float = sum / count
	return mean
#endregion

#TODO: fix this so criteria matches animation state, currently not finished
func animation_handler():
	if (spinning_anticlockwise or spinning_clockwise) and not anim_warmup:
		player_sprite.play("cast_warmup")
		print("warmup")
		anim_warmup = true
	elif (spinning_anticlockwise or spinning_clockwise) and not anim_done:
		if not player_sprite.is_playing():
			anim_done = true
	elif (spinning_anticlockwise or spinning_clockwise) and (anim_warmup and anim_done) and not anim_looping:
		player_sprite.play("cast_loop")
		anim_looping = true
	else:
		player_sprite.play("run")

func _on_net_body_entered(body):
	if body.is_in_group("rat"):
		if spinning_anticlockwise or spinning_clockwise:
			rat_capture.emit(body)
