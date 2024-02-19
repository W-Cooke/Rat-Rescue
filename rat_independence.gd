extends CharacterBody2D

@export var max_speed : float = 300.0

@onready var label = $Label
enum {WANDER, RUNNING, FOLLOWING}
var state = RUNNING

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


func _ready():
	# select a random rat texture and applies it
	var image = sprite_array[randi_range(0, sprite_array.size() - 1)].get_image()
	var texture = ImageTexture.create_from_image(image)
	$Sprite2D.texture = texture

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		state += 1
		if state > 2:
			state = 0
	match(state):
		RUNNING:
			run_from_mouse()
		FOLLOWING:
			follow_the_mouse()
		WANDER:
			wander_around()
	move_and_slide()

func follow_the_mouse():
	label.text = "Following"
	var target_global_position: Vector2 = get_global_mouse_position()
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity = Steering.follow(
			velocity,
			global_position,
			target_global_position,
			max_speed
			)

func run_from_mouse():
	label.text = "Running!"
	var target_global_position: Vector2 = get_global_mouse_position()
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

func wander_steering() -> Vector2:
	wander_angle = randf_range(wander_angle - WANDER_RANDOMNESS, wander_angle + WANDER_RANDOMNESS)
	var vector_to_circle : Vector2 = velocity.normalized() * max_speed
	var desired_velocity : Vector2 = vector_to_circle + Vector2(WANDER_CIRCLE_RADIUS, 0).rotated(wander_angle)
	return desired_velocity - velocity
