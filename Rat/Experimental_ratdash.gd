extends CharacterBody2D
#TODO: first check dash state before adding logic to check criteria <3
# Contained in this file are scripts and algos to be used in rat_independence
# once i have access to the game engine again

#region variable declaration

var position_array : Array = []
var array_max_size : int = 15

#region default directions
var dir_NE : Vector2 = Vector2(1.0, 1.0)
var dir_NW : Vector2 = Vector2(-1.0, 1.0)
var dir_SE : Vector2 = Vector2(1.0, -1.0)
var dir_SW : Vector2 = Vector2(-1.0, -1.0)
#endregion

#region raycasts
@onready var RC_N : Raycast2D = $Raycasts/RaycastNorth
@onready var RC_S : Raycast2D = $Raycasts/RaycastSouth
@onready var RC_E : Raycast2D = $Raycasts/RaycastEast
@onready var RC_W : Raycast2D = $Raycasts/RaycastWest

@onready var raycast_NE : Array[Raycast2D] = [RC_N, RC_E]
@onready var raycast_NW : Array[Raycast2D] = [RC_N, RC_W]
@onready var raycast_SE : Array[Raycast2D] = [RC_S, RC_E]
@onready var raycast_SW : Array[Raycast2D] = [RC_S, RC_W]
#endregion

@onready var dash_timer : Timer = $Timers/DashTimer
@onready var dash_particles : GPUParticles2D = $DashParticles

#endregion

func _ready():
    dash_particles.set_texture(bleepbloop)

func _process():
    pass
    if state == RUNNING and check_for_no_movement():
        direction = decide_corner_direction()
        state = DASH
        rat.set_collision_layer(1, false)
        dash_timer.start()
        #TODO: finish this

func put_this_in_match_statement():
    max_speed *= 3
    # emit particles!
    # make noise!


func decide_corner_direction() -> Vector2:
    randomise_angles()
    if raycast_NE[0].is_colliding and raycast_NE[1].is_colliding:
        return dir_SW
    elif raycast_NW[0].is_colliding and raycast_NW[1].is_colliding:
        return dir_SE
    elif raycast_SE[0].is_colliding and raycast_SE[1]is_colliding:
        return dir_NW
    elif raycast_SW[0].is_colliding and raycast_SW[1].is_colliding:
        return dir_NE
    else:
        return Vector2.ZERO

func check_for_no_movement() -> bool:
    position_array.push(rat.global_position)
    if position_array.size() == array_max_size:
        if array.count(rat.global_position) >= array_max_size - 2: # 2 less than full array size just for some wiggle room
            return true
        else:
            position_array.clear()
    return false

func randomise_angles():
    dir_NE = Vector2(randf_range(0.0, 1.0), randf_range(0.0, 1.0))
    dir_NW = Vector2(randf_range(-1.0, 0.0), randf_range(0.0, 1.0))
    dir_SE = Vector2(randf_range(0.0, 1.0), randf_range(-1.0, 0.0))
    dir_SW = Vector2(randf_range(-1.0, 0.0), randf_range(-1.0, 0.0))

#region timers
func _on_dash_timer_timeout():
    rat.set_collision_layer(1, true)
    max_speed = maximum_speed
    if state == DASH:
        state = RUNNING
    else:
        state = WANDER
#endregion