extends Node

signal rat_caught
#TODO: this signal bus will work as a conduit to pass signals more smoothly from certain things


func _on_rat_independence_rat_caught():
	rat_caught.emit()
