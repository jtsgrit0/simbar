extends Node
class_name TimeSystem

signal minute_passed
signal hour_passed
signal day_changed(day: int)
signal time_updated(time: GameTime)

const MINUTES_PER_HOUR = 60
const HOURS_PER_DAY = 24
const MINUTES_PER_DAY = MINUTES_PER_HOUR * HOURS_PER_DAY

var current_minute: int = 0
var current_day: int = 1
var time_scale: float = 1.0
var is_paused: bool = false
var is_running: bool = false

@export var open_hour: int = 14
@export var close_hour: int = 2
@export var hours_per_minute: float = 0.5


func get_game_time() -> GameTime:
	var total_minutes = current_day * MINUTES_PER_DAY + current_minute
	var hours = int(current_minute / MINUTES_PER_HOUR) % HOURS_PER_DAY
	var minutes = int(current_minute) % MINUTES_PER_HOUR
	return GameTime.new(current_day, hours, minutes, total_minutes)


func is_open() -> bool:
	var hours = int(current_minute / MINUTES_PER_HOUR) % HOURS_PER_DAY
	if open_hour < close_hour:
		return hours >= open_hour and hours < close_hour
	else:
		return hours >= open_hour or hours < close_hour


func start() -> void:
	is_running = true
	is_paused = false
	_process_time()


func pause() -> void:
	is_paused = true


func resume() -> void:
	is_paused = false


func stop() -> void:
	is_running = false
	is_paused = false


func advance_minutes(amount: float) -> void:
	var old_day = current_day
	current_minute += amount
	while current_minute >= MINUTES_PER_DAY:
		current_minute -= MINUTES_PER_DAY
		current_day += 1
		day_changed.emit(current_day)
	if int(current_minute / MINUTES_PER_HOUR) > int((current_minute - amount) / MINUTES_PER_HOUR) % HOURS_PER_DAY:
		hour_passed.emit()
	minute_passed.emit()
	time_updated.emit(get_game_time())


func _process_time() -> void:
	while is_running:
		if not is_paused:
			advance_minutes(hours_per_minute * time_scale)
		await get_tree().create_timer(1.0 / 60.0).timeout


func _process(_delta: float) -> void:
	pass
