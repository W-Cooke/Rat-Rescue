extends AnimatedSprite2D

@onready var portals = get_tree().get_nodes_in_group("portal_blue")
@onready var self_portal = self
var target_portal

func _ready():
	print(portals)
	for x in portals:
		if portals[x] == self_portal:
			portals.remove_at(x)
	target_portal = portals[0]

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.global_position = target_portal.global_position
