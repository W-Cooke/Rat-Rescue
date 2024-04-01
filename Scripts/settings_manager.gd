extends Node

# this script will be used to keep settings as a singleton to move settings around
#TODO: this, it's not nearly complete

var level_1_cleared : bool
var level_2_cleared : bool
var level_3_cleared : bool
var level_4_cleared : bool
var level_5_cleared : bool

var savefile = "user://SaveFile.ini"

func save() -> void:
	var config_file := ConfigFile.new()
	
