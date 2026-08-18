extends Node2D
class_name Main

signal game_saved
signal game_loaded

@onready var time_system: TimeSystem = $TimeSystem
@onready var game_state: GameState = $GameState
@onready var band_manager: BandManager = $BandManager
@onready var concert_manager: ConcertManager = $ConcertManager
@onready var pub_manager: PubManager = $PubManager
@onready var music_system: MusicSystem = $MusicSystem
@onready var ui: CanvasLayer = $UI

var save_path: String = "user://savegame.json"


func _ready() -> void:
	_load_game()
	_connect_signals()
	time_system.start()


func _connect_signals() -> void:
	time_system.day_changed.connect(_on_day_changed)
	time_system.day_changed.connect(band_manager.on_day_changed)
	pub_manager.customer_spawned.connect(_on_customer_spawned)
	pub_manager.customer_served.connect(_on_customer_served)
	concert_manager.concert_starting.connect(_on_concert_starting)
	concert_manager.concert_finished.connect(_on_concert_finished)
	music_system.song_started.connect(_on_song_started)
	music_system.song_finished.connect(_on_song_finished)
	music_system.discovery_unlocked.connect(_on_song_discovered)
	get_tree().create_timer(5.0).timeout.connect(_auto_save)


func _on_day_changed(new_day: int) -> void:
	game_state.day = new_day
	band_manager._refresh_bands()


func _on_customer_spawned(customer_data: Dictionary) -> void:
	var customer_scene = preload("res://scenes/entities/customer.tscn")
	var customer = customer_scene.instantiate()
	customer.customer_id = customer_data["id"]
	customer.drink = customer_data["drink"]
	customer.max_patience = customer_data["max_patience"]
	customer.current_patience = customer_data["patience"]
	if customer.drink_icon:
		customer.drink_icon.color = customer.drink.icon_color if customer.drink else Color.GRAY
	customer.clicked.connect(_on_customer_clicked)
	var spawn_x = randf_range(80, 400)
	var spawn_y = randf_range(300, 500)
	customer.position = Vector2(spawn_x, spawn_y)
	add_child(customer)
	pub_manager.attach_node(customer_data["id"], customer)


func _on_customer_clicked(customer: Customer) -> void:
	if customer.state != "waiting":
		return
	var all_customers = get_tree().get_nodes_in_group("customers")
	for c in all_customers:
		if c is Customer and c != customer and c.is_selected:
			c.deselect()
	customer.select()
	pub_manager.serve_customer(customer.customer_id)




func _on_customer_served(customer_id: int, drink_id: String, revenue: int) -> void:
	game_state.reputation = min(game_state.reputation + 0.02, 10.0)


func _on_concert_starting(band: Band) -> void:
	pub_manager.start_concert(band)


func _on_concert_finished(band: Band, success: bool, revenue: int, attendance: int) -> void:
	if success:
		game_state.reputation += 0.5
	else:
		game_state.reputation -= 0.2
	game_state.reputation = clamp(game_state.reputation, 0.0, 10.0)
	game_state.update_stats("total_concerts", 1)
	music_system.try_discover_from_concert(band)


func _auto_save() -> void:
	_save_game()


func _save_game() -> void:
	var data = game_state.to_dict()
	data["current_day"] = time_system.current_day
	data["current_minute"] = time_system.current_minute
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		game_saved.emit()


func _load_game() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return
	var text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if data:
		game_state.from_dict(data)
		if "current_day" in data:
			time_system.current_day = data["current_day"]
		if "current_minute" in data:
			time_system.current_minute = data["current_minute"]
		game_loaded.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_save_game()
		get_tree().quit()


func _on_song_started(song: Song) -> void:
	pass


func _on_song_finished(song: Song) -> void:
	pass


func _on_song_discovered(song: Song) -> void:
	pass


func _process(delta: float) -> void:
	concert_manager.update_concert(delta)
