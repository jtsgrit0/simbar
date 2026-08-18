class_name DrinkDatabase
extends RefCounted

static var drinks: Array[Drink] = [
	Drink.new("beer", "Pub Beer", "Classic cold beer", 5000, 2000, 0.8, Color("#F4A460"), 1),
	Drink.new("cider", "Apple Cider", "Sweet and crisp", 6000, 2500, 0.6, Color("#DEB887"), 1),
	Drink.new("wine", "House Wine", "Red table wine", 8000, 3500, 0.5, Color("#8B0000"), 3),
	Drink.new("whiskey", "Whiskey", "Aged malt whiskey", 12000, 5000, 0.4, Color("#DAA520"), 5),
	Drink.new("cocktail", "Signature Cocktail", "Bartender's special", 15000, 6000, 0.7, Color("#FF69B4"), 7),
	Drink.new("non_alc", "Sparkling Soda", "For non-drinkers", 4000, 1500, 0.3, Color("#98FB98"), 1),
]

static func get_drink(id: String) -> Drink:
	for d in drinks:
		if d.id == id:
			return d
	return null

static func get_unlocked_drinks(current_day: int) -> Array[Drink]:
	var result: Array[Drink] = []
	for d in drinks:
		d.check_unlock(current_day)
		if d.unlocked:
			result.append(d)
	return result
