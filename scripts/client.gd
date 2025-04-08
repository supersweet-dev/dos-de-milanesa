extends Node2D


var order: Array = [] # Declare order as an empty array
var order_checker: Callable # Declare order_checker as a Callable
var tip_amount: int = 0 # Declare tip_amount as an integer

func set_order(new_order: Array):
	order = new_order

func set_checker(checker: Callable):
	order_checker = checker

func set_tip(tip: int):
	tip_amount = tip
