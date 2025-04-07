extends Node2D

@onready var menu_button = $MenuButton  
@onready var language_button = $LanguageButton
@onready var instruction_sprite = $"Controls-screen" 

var english_texture = preload("res://assets/menus/instructions-en.svg")
var spanish_texture = preload("res://assets/menus/instructions-es.svg")

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)
	language_button.pressed.connect(_on_language_toggled)
	instruction_sprite.texture = spanish_texture
	

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/screens/main_menu.tscn")  

func _on_language_toggled():
	if instruction_sprite.texture == english_texture:
		instruction_sprite.texture = spanish_texture
		language_button.text = "ENGLISH"
	else:
		instruction_sprite.texture = english_texture
		language_button.text = "SPANISH"
