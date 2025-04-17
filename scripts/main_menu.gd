extends Node2D

@onready var start_button = $StartButton
@onready var controls_button = $ControlsButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	controls_button.pressed.connect(_on_controls_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/screens/level.tscn")

func _on_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/screens/controls.tscn")
