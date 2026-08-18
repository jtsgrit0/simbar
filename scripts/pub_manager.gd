extends Node
class_name PubManager

signal customer_served(customer_id: int, drink_id: String, revenue: int)
signal customer_spawned(customer_data: Dictionary)
signal concert_started(band_name: String)
signal concert_ended(band_name: String, success: bool)
signal customer_left(customer_id: int)

var time_system: TimeSystem
var game_state: GameState
var band_manager: BandManager
var concert_manager: ConcertManager

var active_customers: Dictionary = {}
var customer_id_counter: int = 0

var spawn_timer: float = 0.0
var spawn_interval: float = 3.0
var max_spawn_rate: float = 1.0


func _ready() -> void:
	time_system = get_node_or_null("/root/Main/TimeSystem")
	game_state = get_node_or_null("/root/Main/GameState")
	band_manager = get_node_or_null("/root/Main/BandManager")
	concert_manager = get_node_or_null("/root/Main/ConcertManager")


func _process(delta: float) -> void:
	if time_system and time_system.is_running and not time_system.is_paused:
		if time_system.is_open():
			_update_customer_spawning(delta)
			_process_orders(delta)


func _update_customer_spawning(delta: float) -> void:
	if active_customers.size() >= game_state.max_customers:
		return
	spawn_timer += delta
	var effective_interval = spawn_interval - (game_state.reputation * 0.2)
	effective_interval = max(effective_interval, max_spawn_rate)
	if spawn_timer >= effective_interval:
		spawn_timer = 0.0
		_spawn_customer()


func _spawn_customer() -> void:
	var customer_id = customer_id_counter
	customer_id_counter += 1
	var drinks = DrinkDatabase.get_unlocked_drinks(game_state.day)
	if drinks.is_empty():
		return
	var drink = drinks.pick_random()
	var patience = randf_range(15.0, 30.0)
	var customer_data = {
		"id": customer_id,
		"drink": drink,
		"patience": patience,
		"max_patience": patience,
		"state": "waiting",
		"serve_timer": 0.0,
		"node": null,
	}
	active_customers[customer_id] = customer_data
	customer_spawned.emit(customer_data)


func attach_node(customer_id: int, node: Node2D) -> void:
	if customer_id in active_customers:
		active_customers[customer_id]["node"] = node


func _process_orders(delta: float) -> void:
	for id in active_customers.keys():
		var customer = active_customers[id]
		if customer.state == "waiting":
			customer.patience -= delta
			if customer.patience <= 0:
				customer.state = "left"
				var node = customer.get("node")
				if node and is_instance_valid(node):
					node.queue_free()
				customer_left.emit(id)
				active_customers.erase(id)
		elif customer.state == "serving":
			customer.serve_timer -= delta
			if customer.serve_timer <= 0:
				_finish_order(customer)


func serve_customer(customer_id: int) -> void:
	if not customer_id in active_customers:
		return
	var customer = active_customers[customer_id]
	if customer.state != "waiting":
		return
	customer.state = "serving"
	customer.serve_timer = 1.5
	var node = customer.get("node")
	if node and node.has_method("deseelect"):
		node.deselect()
	if node and node.has_method("select"):
		node.select()


func _finish_order(customer: Dictionary) -> void:
	var revenue = customer.drink.price
	game_state.add_money(revenue)
	game_state.update_stats("total_served", 1)
	game_state.update_stats("total_drinks_sold", 1)
	var node = customer.get("node")
	if node and node.has_method("serve"):
		node.serve()
	customer_served.emit(customer.id, customer.drink.id, revenue)
	active_customers.erase(customer.id)


func cancel_customer(customer_id: int) -> void:
	if customer_id in active_customers:
		var node = active_customers[customer_id].get("node")
		if node and is_instance_valid(node):
			node.queue_free()
		active_customers.erase(customer_id)


func get_customer_count() -> int:
	return active_customers.size()


func get_active_customers() -> Array:
	return active_customers.values()


func start_concert(band: Band) -> void:
	concert_started.emit(band.name)


func end_concert(band: Band, success: bool) -> void:
	concert_ended.emit(band.name, success)
