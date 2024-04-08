extends AnimatedSprite2D

@onready var poof_particles = $PoofParticles
@onready var tp_sound = $Bwoop
@onready var portals = get_tree().get_nodes_in_group("portal_blue")
var target_portal
@onready var cooldown_timer = $CooldownTimer
var tp_cooldown : bool = true
signal teleported

func _ready():
	print(portals)
	if portals[0] == self:
		print("removed portal at index 0")
		portals.remove_at(0)
	elif portals[1] == self:
		print("removed portal at index 1")
		portals.remove_at(1)
	target_portal = portals[0]
	print("target portal: " + str(target_portal))

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and tp_cooldown:
		teleported.emit()
		cooldown_timer.start()
		body.global_position = target_portal.global_position


func _on_cooldown_timer_timeout():
	tp_cooldown = true

func _on_portal_blue_teleported():
	tp_sound.play()
	tp_cooldown = false
	cooldown_timer.start()
	poof_particles.emitting = true
