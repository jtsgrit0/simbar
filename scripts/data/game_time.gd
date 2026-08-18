class_name GameTime
extends RefCounted

var day: int
var hour: int
var minute: int
var total_minutes: int

func _init(p_day: int = 1, p_hour: int = 14, p_minute: int = 0, p_total: int = 0):
	day = p_day
	hour = p_hour
	minute = p_minute
	total_minutes = p_total

func get_formatted_time() -> String:
	var h = str(hour).pad_zeros(2)
	var m = str(minute).pad_zeros(2)
	return "%s:%s" % [h, m]

func get_formatted_date() -> String:
	return "Day %d" % day
