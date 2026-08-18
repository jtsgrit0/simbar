extends Node
class_name BandManager

signal bands_updated
signal band_booked(band: Band)
signal band_unbooked(band_id: String)

var game_state
var available_bands: Array[Band] = []


func _ready() -> void:
	game_state = get_node_or_null("/root/Main/GameState") as GameState
	_refresh_bands()


func _refresh_bands() -> void:
	available_bands = BandDatabase.get_available_bands(game_state.day, game_state.booked_bands)
	bands_updated.emit()


func get_available_bands() -> Array[Band]:
	return available_bands


func book_band(band_id: String) -> bool:
	var band = null
	for b in available_bands:
		if b.id == band_id:
			band = b
			break
	if not band:
		return false
	if game_state.spend_money(band.fee):
		band.is_booked = true
		band.booked_day = game_state.day
		game_state.book_band(band)
		band_booked.emit(band)
		_refresh_bands()
		return true
	return false


func unbook_band(band_id: String) -> void:
	var band = null
	for b in available_bands:
		if b.id == band_id:
			band = b
			break
	if band:
		band.is_booked = false
		band.booked_day = -1
		game_state.booked_bands.erase(band_id)
		band_unbooked.emit(band_id)
		_refresh_bands()


func on_day_changed(_new_day: int) -> void:
	for id in game_state.booked_bands:
		for b in BandDatabase.bands:
			if b.id == id:
				b.is_booked = false
				b.booked_day = -1
				break
	game_state.booked_bands.clear()
	_refresh_bands()


func get_booked_today() -> Array[Band]:
	var result: Array[Band] = []
	for b in available_bands:
		if b.is_booked and b.booked_day == game_state.day:
			result.append(b)
	return result
