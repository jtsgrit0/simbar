class_name Song
extends RefCounted

enum Genre { INDIE_ROCK, INDIE_FOLK, JAZZ, LOUNGE, ELECTRONICA, ACOUSTIC, PUNK, SOUL }

var id: String
var title: String
var artist: String
var band_id: String
var genre: Genre
var duration_sec: float
var bpm: int
var mood: String
var unlock_day: int
var unlocked: bool = false
var stream_path: String = ""

func _init(p_id: String, p_title: String, p_artist: String, p_band: String, p_genre: Genre, p_duration: float, p_bpm: int, p_mood: String, p_unlock: int):
	id = p_id
	title = p_title
	artist = p_artist
	band_id = p_band
	genre = p_genre
	duration_sec = p_duration
	bpm = p_bpm
	mood = p_mood
	unlock_day = p_unlock

func get_genre_string() -> String:
	match genre:
		Genre.INDIE_ROCK: return "Indie Rock"
		Genre.INDIE_FOLK: return "Indie Folk"
		Genre.JAZZ: return "Jazz"
		Genre.LOUNGE: return "Lounge"
		Genre.ELECTRONICA: return "Electronica"
		Genre.ACOUSTIC: return "Acoustic"
		Genre.PUNK: return "Punk"
		Genre.SOUL: return "Soul"
	return "Unknown"

func check_unlock(current_day: int) -> void:
	if current_day >= unlock_day:
		unlocked = true
