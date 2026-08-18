extends Node
class_name GameState

signal money_changed(amount: int)
signal stats_updated(stats: Dictionary)

var money: int = 500000
var total_earned: int = 0
var reputation: float = 0.0
var day: int = 1
var booked_bands: Array = []
var discovered_songs: Array = []
var max_customers: int = 20
var current_customers: int = 0
var decor_level: int = 1
var music_level: int = 1
var stats: Dictionary = {
	"total_served": 0,
	"total_drinks_sold": 0,
	"total_concerts": 0,
	"total_concert_attendance": 0,
	"best_day_earnings": 0,
}

func add_money(amount: int) -> void:
	money += amount
	if amount > 0:
		total_earned += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func update_stats(key: String, value: int) -> void:
	if key in stats:
		stats[key] += value
		stats_updated.emit(stats)

func book_band(band: Band) -> bool:
	if band.id in booked_bands:
		return false
	booked_bands.append(band.id)
	return true

func is_band_booked(band_id: String) -> bool:
	return band_id in booked_bands

func get_booked_bands_count() -> int:
	return booked_bands.size()

func discover_song(song: Song) -> void:
	if song.id not in discovered_songs:
		discovered_songs.append(song.id)

func is_song_discovered(song_id: String) -> bool:
	return song_id in discovered_songs

func to_dict() -> Dictionary:
	return {
		"money": money,
		"total_earned": total_earned,
		"reputation": reputation,
		"day": day,
		"booked_bands": booked_bands,
		"discovered_songs": discovered_songs,
		"max_customers": max_customers,
		"current_customers": current_customers,
		"decor_level": decor_level,
		"music_level": music_level,
		"stats": stats.duplicate(),
	}

func from_dict(data: Dictionary) -> void:
	money = data.get("money", money)
	total_earned = data.get("total_earned", total_earned)
	reputation = data.get("reputation", reputation)
	day = data.get("day", day)
	booked_bands = data.get("booked_bands", [])
	discovered_songs = data.get("discovered_songs", [])
	max_customers = data.get("max_customers", max_customers)
	current_customers = data.get("current_customers", current_customers)
	decor_level = data.get("decor_level", decor_level)
	music_level = data.get("music_level", music_level)
	stats = data.get("stats", stats.duplicate())

func reset() -> void:
	money = 500000
	total_earned = 0
	reputation = 0.0
	day = 1
	booked_bands = []
	discovered_songs = []
	max_customers = 20
	current_customers = 0
	decor_level = 1
	music_level = 1
	stats = {
		"total_served": 0,
		"total_drinks_sold": 0,
		"total_concerts": 0,
		"total_concert_attendance": 0,
		"best_day_earnings": 0,
	}
