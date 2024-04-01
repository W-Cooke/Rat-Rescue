extends Node

# this script will be used to keep settings as a singleton to move settings around

var level_1_cleared : bool
var level_2_cleared : bool
var level_3_cleared : bool
var level_4_cleared : bool
var level_5_cleared : bool

var savefile = "res://"

func _ready():
	check_states()

func check_states():
	if FileAccess.file_exists()
