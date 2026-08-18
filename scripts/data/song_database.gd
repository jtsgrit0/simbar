class_name SongDatabase
extends RefCounted

static var songs: Array[Song] = [
	Song.new("mc_01", "Morning Brew", "Morning Coffee", "morning_coffee", Song.Genre.ACOUSTIC, 185.0, 92, "warm", 1),
	Song.new("mc_02", "Porch Light", "Morning Coffee", "morning_coffee", Song.Genre.ACOUSTIC, 210.0, 88, "cozy", 3),
	Song.new("vn_01", "Smoky Velvet", "Velvet Night", "velvet_night", Song.Genre.JAZZ, 245.0, 104, "smooth", 2),
	Song.new("vn_02", "Blue Note Late", "Velvet Night", "velvet_night", Song.Genre.JAZZ, 268.0, 112, "late", 5),
	Song.new("nd_01", "Neon Pulse", "Neon Dreams", "neon_dreams", Song.Genre.ELECTRONICA, 200.0, 128, "energetic", 4),
	Song.new("nd_02", "After Hours", "Neon Dreams", "neon_dreams", Song.Genre.ELECTRONICA, 320.0, 118, "chill", 6),
	Song.new("rs_01", "Wooden Heart", "Rusty Strings", "rusty_strings", Song.Genre.INDIE_FOLK, 195.0, 96, "warm", 1),
	Song.new("rs_02", "Campfire Stories", "Rusty Strings", "rusty_strings", Song.Genre.INDIE_FOLK, 240.0, 90, "cozy", 4),
	Song.new("tu_01", "Cut Loose", "The Undercut", "the_undercut", Song.Genre.PUNK, 160.0, 170, "energetic", 5),
	Song.new("tu_02", "Back Alley", "The Undercut", "the_undercut", Song.Genre.PUNK, 175.0, 180, "raw", 7),
	Song.new("ms_01", "Slow Burn", "Midnight Soul", "midnight_soul", Song.Genre.SOUL, 230.0, 94, "smooth", 6),
	Song.new("ms_02", "Golden", "Midnight Soul", "midnight_soul", Song.Genre.SOUL, 260.0, 98, "warm", 8),
	Song.new("ec_01", "Feedback Loop", "Echo Chamber", "echo_chamber", Song.Genre.INDIE_ROCK, 210.0, 140, "energetic", 3),
	Song.new("ec_02", "Static Hymn", "Echo Chamber", "echo_chamber", Song.Genre.INDIE_ROCK, 275.0, 132, "dreamy", 6),
	Song.new("ll_01", "Satin Sheets", "Lantern Light", "lantern_light", Song.Genre.LOUNGE, 290.0, 86, "smooth", 2),
	Song.new("ll_02", "Last Call", "Lantern Light", "lantern_light", Song.Genre.LOUNGE, 310.0, 80, "late", 5),
	Song.new("cg_01", "Concrete Bloom", "Concrete Garden", "concrete_garden", Song.Genre.INDIE_ROCK, 255.0, 138, "dreamy", 7),
	Song.new("cg_02", "Skyline Haze", "Concrete Garden", "concrete_garden", Song.Genre.INDIE_ROCK, 290.0, 142, "energetic", 9),
	Song.new("pk_01", "Kite Song", "Paper Kite", "paper_kite", Song.Genre.INDIE_FOLK, 180.0, 84, "cozy", 1),
	Song.new("pk_02", "Paper Moon", "Paper Kite", "paper_kite", Song.Genre.INDIE_FOLK, 200.0, 86, "warm", 3),
]

static func get_songs_for_band(band_id: String) -> Array[Song]:
	var result: Array[Song] = []
	for s in songs:
		if s.band_id == band_id:
			result.append(s)
	return result

static func get_unlocked_songs(current_day: int) -> Array[Song]:
	var result: Array[Song] = []
	for s in songs:
		s.check_unlock(current_day)
		if s.unlocked:
			result.append(s)
	return result

static func discover_song(current_day: int, band_id: String) -> Song:
	var candidates: Array[Song] = []
	for s in songs:
		if s.band_id == band_id and not s.unlocked and current_day >= s.unlock_day:
			candidates.append(s)
	if candidates.is_empty():
		return null
	var song = candidates.pick_random()
	song.unlocked = true
	return song
