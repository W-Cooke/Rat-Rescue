extends CharacterBody2D

@export var max_speed : float = 500.0
@export_category("Rat Sprites")
@export var rat_sprite_1 : CompressedTexture2D
@export var rat_sprite_2 : CompressedTexture2D
@export var rat_sprite_3 : CompressedTexture2D
@export var rat_sprite_4 : CompressedTexture2D

@onready var sprite_array : Array = [rat_sprite_1, rat_sprite_2, rat_sprite_3, rat_sprite_4]

func _ready():
	var image = sprite_array[randi_range(0, 3)].get_image()
	var texture = ImageTexture.create_from_image(image)
	$Sprite2D.texture = texture

func _physics_process(delta):
	var target_global_position: Vector2 = get_global_mouse_position()
	
	velocity = Steering.follow(
		velocity,
		global_position,
		target_global_position,
		max_speed
		)
	move_and_slide()
