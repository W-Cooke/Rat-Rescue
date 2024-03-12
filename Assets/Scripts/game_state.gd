extends Node

# TODO: game state manager for level transitions, add this to autoload so it can always be used.

# set to number of total levels in the game
Var level_num : int = 2
var current_level : int = 0
var game_scene = "add the string to link the scene here"
var title_scene = "add the title scene here"

func restart():
    current_level = 0
    get_tree().change_scene_to_file(title_scene)

func next_level():
    current_level += 1
    if current_level <= level_num:
        get_tree().change_scene_to_file(game_scene)