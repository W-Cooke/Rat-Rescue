@tool
extends Control

@export var level_index : int = 1
@export var level_texture : CompressedTexture2D

var playable = false
@onready var anim = $Anim

func _ready():
	$Label.text = "Level " + str(level_index)
	$TextureRect.texture = level_texture

func shake():
	anim.play("shake")

func open_level():
	$Padlock.hide()
	playable = true

func _process(delta):
	if Engine.is_editor_hint():
		$Label.text = "Level " + str(level_index)
		$TextureRect.texture = level_texture
