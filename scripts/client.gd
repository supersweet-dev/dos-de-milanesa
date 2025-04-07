extends Node2D


var order: Array # Declare order as an empty array

func set_order(new_order: Array):
	order = new_order

func _ready():
	order = GameData.get_random_order()
