extends Node
class_name ConcertManager

signal concert_scheduled(band: Band, day: int)
signal concert_starting(band: Band)
signal concert_finished(band: Band, success: bool, revenue: int, attendance: int)
signal no_concert_today

var game_state: GameState
var time_system: TimeSystem
var band_manager: BandManager

var scheduled_concert: Dictionary = {}
var is_concert_active: bool = false
var concert_timer: float = 0.0
var concert_duration: float = 60.0


func _ready() -> void:
	game_state = get_node_or_null("/root/Main/GameState") as GameState
	time_system = get_node_or_null("/root/Main/TimeSystem") as TimeSystem
	band_manager = get_node_or_null("/root/Main/BandManager") as BandManager
	if time_system:
		time_system.hour_passed.connect(_on_hour_passed)


func _on_hour_passed() -> void:
	if is_concert_active:
		return
	var booked = band_manager.get_booked_today()
	if booked.is_empty():
		no_concert_today.emit()
		return
	var band = booked[0]
	scheduled_concert = {
		"band": band,
		"day": game_state.day,
		"started": false,
	}


func start_concert() -> void:
	if scheduled_concert.is_empty():
		return
	var band = scheduled_concert["band"]
	if not band:
		return
	is_concert_active = true
	concert_timer = 0.0
	concert_starting.emit(band)


func update_concert(delta: float) -> void:
	if not is_concert_active:
		return
	concert_timer += delta
	if concert_timer >= concert_duration:
		_finish_concert()


func _finish_concert() -> void:
	if scheduled_concert.is_empty():
		return
	var band = scheduled_concert["band"]
	var success = _calculate_success(band)
	var revenue = band.expected_revenue if success else int(band.expected_revenue * 0.3)
	var attendance = band.min_attendance if success else int(band.min_attendance * 0.5)
	game_state.add_money(revenue)
	game_state.update_stats("total_concerts", 1)
	game_state.update_stats("total_concert_attendance", attendance)
	if revenue > game_state.stats["best_day_earnings"]:
		game_state.stats["best_day_earnings"] = revenue
	game_state.reputation += 0.5 if success else -0.2
	is_concert_active = false
	concert_finished.emit(band, success, revenue, attendance)
	scheduled_concert.clear()


func _calculate_success(band: Band) -> bool:
	var base_chance = band.skill_level * 0.15
	var pop_factor = band.popularity * 0.002
	var total = base_chance + pop_factor + (game_state.music_level * 0.05)
	return randf() < total


func _process(delta: float) -> void:
	if is_concert_active:
		update_concert(delta)


func get_concert_state() -> Dictionary:
	return {
		"is_active": is_concert_active,
		"progress": concert_timer / concert_duration if concert_duration > 0 else 0.0,
		"band": scheduled_concert.get("band", null),
	}
