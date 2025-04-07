extends Node2D

@onready var final_score_label = $FinalScore
@onready var menu_button = $MenuButton  

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)
	final_score_label.text = "Hoy Ganamos: " + str(GameData.final_score) 

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/screens/main_menu.tscn")  
