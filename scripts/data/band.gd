class_name Band
extends RefCounted

enum Genre { INDIE_ROCK, INDIE_FOLK, JAZZ, LOUNGE, ELECTRONICA, ACOUSTIC, PUNK, SOUL }

var id: String
var name: String
var genre: Genre
var skill_level: int
var popularity: int
var fee: int
var min_attendance: int
var expected_revenue: int
var contract_length_days: int
var is_booked: bool = false
var booked_day: int = -1

func _init(p_id: String, p_name: String, p_genre: Genre, p_skill: int, p_pop: int, p_fee: int, p_attendance: int, p_revenue: int, p_contract: int = 1):
	id = p_id
	name = p_name
	genre = p_genre
	skill_level = p_skill
	popularity = p_pop
	fee = p_fee
	min_attendance = p_attendance
	expected_revenue = p_revenue
	contract_length_days = p_contract

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

func get_star_rating() -> String:
	var stars = ""
	for i in range(skill_level):
		stars += "★"
	for i in range(5 - skill_level):
		stars += "☆"
	return stars
