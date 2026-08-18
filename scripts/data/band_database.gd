class_name BandDatabase
extends RefCounted

static var bands: Array[Band] = [
	Band.new("morning_coffee", "Morning Coffee", Band.Genre.ACOUSTIC, 2, 20, 30000, 15, 45000, 1),
	Band.new("velvet_night", "Velvet Night", Band.Genre.JAZZ, 3, 35, 50000, 25, 80000, 1),
	Band.new("neon_dreams", "Neon Dreams", Band.Genre.ELECTRONICA, 4, 50, 70000, 40, 120000, 1),
	Band.new("rusty_strings", "Rusty Strings", Band.Genre.INDIE_FOLK, 3, 30, 40000, 20, 60000, 1),
	Band.new("the_undercut", "The Undercut", Band.Genre.PUNK, 4, 45, 45000, 35, 100000, 1),
	Band.new("midnight_soul", "Midnight Soul", Band.Genre.SOUL, 5, 60, 80000, 50, 150000, 2),
	Band.new("echo_chamber", "Echo Chamber", Band.Genre.INDIE_ROCK, 4, 55, 65000, 45, 110000, 1),
	Band.new("lantern_light", "Lantern Light", Band.Genre.LOUNGE, 3, 25, 35000, 18, 50000, 1),
	Band.new("concrete_garden", "Concrete Garden", Band.Genre.INDIE_ROCK, 5, 70, 90000, 55, 180000, 2),
	Band.new("paper_kite", "Paper Kite", Band.Genre.INDIE_FOLK, 2, 15, 25000, 12, 35000, 1),
]

static func get_available_bands(current_day: int, booked_ids: Array) -> Array[Band]:
	var result: Array[Band] = []
	for b in bands:
		if not b.is_booked and b.id not in booked_ids:
			if current_day >= 1:
				result.append(b)
	return result
