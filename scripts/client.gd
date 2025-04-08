# Client.gd - Modified version
extends Node2D

var order: Array = []
var order_checker: Callable
var tip_amount: int = 0
var max_wait_time: float = 0.0 # in seconds
var spawn_time: float = 0.0 # time when client was spawned

func set_max_wait_time(max_wait: float):
	max_wait_time = max_wait

# Returns remaining wait time in seconds
func get_remaining_time(current_time: float) -> float:
	return max(0.0, max_wait_time - (current_time - spawn_time))

func set_order(new_order: Array):
	order = new_order

func set_checker(checker: Callable):
	order_checker = checker

func set_tip(tip: int):
	tip_amount = tip

# Call this when client is spawned
func set_spawn_time(time: float):
	spawn_time = time
