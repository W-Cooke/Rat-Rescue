extends CharacterBody2D

#region Variables
@export var SPEED = 75.00
signal net_spin

# spinning script variables
@export_category ("Spin Variables")
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
#endregion

func _physics_process(delta):
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
	if velocity.x != 0:
		$PlayerSprite.flip_h = velocity.x < 0
	move_and_slide()
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
			# triggers every time the array gets pushed to a certain size, current size is 20 so that takes 20 frames to fill
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

# function to handle spinning state of net
func handle_bools(state):
	# I really wanted to use the match statement, this felt like a good use
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
#endregion


func _on_net_body_entered(body):
	if body.is_in_group("rats"):
		if spinning_anticlockwise or spinning_clockwise:
			body.queue_free()
