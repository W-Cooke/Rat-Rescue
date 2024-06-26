extends Node

#region variable declaration
var tutorial_done : bool
var level_1_complete : bool 
var level_2_complete : bool 
var level_3_complete : bool 
var level_4_complete : bool 
var level_5_complete : bool 
#endregion

var game_complete : bool
var music_on : bool 
var sfx_on : bool 
var controller_used : bool 

func _ready():
	if FileAccess.file_exists("user://savedgame.tres"):
		load_game()
	else:
		tutorial_done = false
		level_1_complete = false
		level_2_complete = false
		level_3_complete = false
		level_4_complete = false
		level_5_complete = false
		music_on = true
		sfx_on = true
		controller_used = false
		game_complete = false
		save_game()

func save_game():
	var saved_game : SavedGame = SavedGame.new()
	#region variables
	saved_game.tutorial_done = tutorial_done
	saved_game.level_1_complete = level_1_complete
	saved_game.level_2_complete = level_2_complete
	saved_game.level_3_complete = level_3_complete
	saved_game.level_4_complete = level_4_complete
	saved_game.level_5_complete = level_5_complete
	saved_game.music_on = music_on
	saved_game.sfx_on = sfx_on
	saved_game.controller_used = controller_used
	saved_game.game_complete = game_complete
	#endregion
	ResourceSaver.save(saved_game, "user://savedgame.tres")

func load_game():
	var saved_game :SavedGame = load("user://savedgame.tres") as SavedGame
	#region variables
	tutorial_done = saved_game.tutorial_done
	level_1_complete = saved_game.level_1_complete
	level_2_complete = saved_game.level_2_complete
	level_3_complete = saved_game.level_3_complete
	level_4_complete = saved_game.level_4_complete
	level_5_complete = saved_game.level_5_complete
	music_on = saved_game.music_on
	sfx_on = saved_game.sfx_on
	controller_used = saved_game.controller_used
	game_complete = saved_game.game_complete
	#endregion

#debug for resetting save file
func reset_info():
	tutorial_done = false
	level_1_complete = false
	level_2_complete = false
	level_3_complete = false
	level_4_complete = false
	level_5_complete = false
	music_on = true
	sfx_on = true
	controller_used = false
	game_complete = false
	save_game()
