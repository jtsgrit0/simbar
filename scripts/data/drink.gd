class_name Drink
extends RefCounted

var id: String
var name: String
var description: String
var price: int
var cost: int
var popularity: float
var icon_color: Color
var unlock_day: int = 1
var unlocked: bool = false

func _init(p_id: String, p_name: String, p_desc: String, p_price: int, p_cost: int, p_pop: float, p_color: Color, p_unlock: int = 1):
	id = p_id
	name = p_name
	description = p_desc
	price = p_price
	cost = p_cost
	popularity = p_pop
	icon_color = p_color
	unlock_day = p_unlock
	unlocked = false

func get_profit() -> int:
	return price - cost

func check_unlock(current_day: int) -> void:
	if current_day >= unlock_day:
		unlocked = true
