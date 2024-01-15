extends Area2D

# player control variables
@export var speed : int = 125
var velocity = Vector2.ZERO
var screensize = Vector2(720,720)

signal net_spin

# spinning script variables
@export var angle_threshold : float = 200.0
@export var array_size : int = 20
var current_angle = 0.0
var previous_angle = 0.0
var angle_array = [0.0]
var spinning_clockwise = false
var spinning_anticlockwise = false
enum {CLOCKWISE, ANTICLOCKWISE, NOT}

# node variables
@onready var net = $Net
@onready var netsprite = $Net/NetSprite
@onready var particles = $Net/GPUParticles2D

func handle_input(delta):
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += velocity * speed * delta
	if velocity.x != 0:
		$PlayerSprite.flip_h = velocity.x < 0

func controller_angle():
	var stick_rotation : Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y), Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
	stick_rotation.x *= -1.0
	if stick_rotation.length() > 0.3:
		current_angle = rad_to_deg(stick_rotation.angle())
		net.rotation = deg_to_rad(current_angle)
		var angle_diff = previous_angle - current_angle
		if (angle_diff >= angle_threshold) or (angle_diff <= -angle_threshold):
			pass
		else:
			angle_array.push_front(angle_diff)
		if angle_array.size() > array_size:
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

func _process(delta):
	handle_input(delta)
	controller_angle()

# function to handle spinning state of net
func handle_bools(state):
	match state:
		CLOCKWISE:
			spinning_anticlockwise = false
			spinning_clockwise = true
			netsprite.flip_h = false
			particles.emitting = true
		ANTICLOCKWISE:
			spinning_anticlockwise = true
			spinning_clockwise = false
			netsprite.flip_h = true
			particles.emitting = true
		NOT:
			spinning_anticlockwise = false
			spinning_clockwise = false
			particles.emitting = false

# calculates mean, who would've guessed!
func calculate_mean(arr):
	var sum = 0.0
	var count = arr.size()
	for i in arr:
		sum += i
	var mean : float = sum / count
	return mean
