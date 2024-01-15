extends Area2D

# player control variables
@export var speed : int = 125
var velocity = Vector2.ZERO
var screensize = Vector2(720,720)


# spinning script variables
var current_angle = 0.0
var previous_angle = 0.0
var angle_array = [0.0]
var spinnning_clockwise = false
var spinning_anticlockwise = false
var array_size : int = 1

@onready var net = $Net

func handle_input(delta):
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += velocity * speed * delta
	if velocity.x != 0:
		$PlayerSprite.flip_h = velocity.x < 0

func controller_angle():
	var stick_rotation : Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y), Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
	stick_rotation.y *= -1.0
	if stick_rotation.length() > 0.3:
		current_angle = rad_to_deg(stick_rotation.angle())
		net.rotation = deg_to_rad(current_angle)
	

func _process(delta):
	handle_input(delta)
	controller_angle()
