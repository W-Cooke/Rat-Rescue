extends Node

# This autoload script (acts as a singleton) is used by the rats to either follow or avoid the player by
# adding velocity incrementally to the current velocity

#region steering
const DEFAULT_MASS : float = 2.0
const DEFAULT_MAX_SPEED : float = 400.00
#endregion

# by taking in current velocity, position between self and target, and mass (which functions as steering speed) 
# this results in very naturalistic movement towards the target, accounting for the target moving positions also
static func follow(
		velocity : Vector2,
		global_position : Vector2,
		target_position : Vector2,
		max_speed := DEFAULT_MAX_SPEED,
		mass := DEFAULT_MASS
	) -> Vector2:
	var desired_velocity := (target_position - global_position).normalized() * max_speed
	var steering := (desired_velocity - velocity) / mass
	return velocity + steering

# this method serves as the opposite to follow, creating naturalistic movement away from the target
static func run_away(
		velocity : Vector2,
		global_position : Vector2,
		target_position : Vector2,
		max_speed := DEFAULT_MAX_SPEED,
		mass := DEFAULT_MASS
	) -> Vector2:
	var desired_velocity := (global_position - target_position).normalized() * max_speed
	var steering := (desired_velocity - velocity) / mass
	return velocity + steering


