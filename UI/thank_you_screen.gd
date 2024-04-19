extends Control

func _input(event):
	if event.is_action_released("ui_accept") or event.is_action_released("ui_cancel"):
		return_to_menu()

func _on_timer_timeout():
	return_to_menu()

func return_to_menu():
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://main_menu.tscn")
