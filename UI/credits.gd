extends Control

@onready var file = "res://credits.txt"
@onready var credits_label = $CreditsLabel
var screen_size

func _ready():
	credits_label.text = load_file(file)

func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	var content = f.get_as_text()
	return content
