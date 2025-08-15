@tool
extends Resource
class_name Date

const _MONTH_NAMES : Array[String] = [
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
]

const _DAY_NAMES : Array[String] = [
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
	"Sunday"
]

const _DAYS_IN_MONTH : Array[int] = [
	-1,  # INVALID
	31,  # January
	28,  # February
	31,  # March
	30,  # April
	31,  # May
	30,  # June
	31,  # July
	31,  # August
	30,  # September
	31,  # October
	30,  # November
	31   # December
]

@export var year : int = 1970:
	set(value):
		year = value
		day = day # re-trigger day-setter
@export var month : int = 1:
	set(value):
		month = clamp(value, 1, 12)
		day = day # re-trigger day-setter
@export var day : int = 1:
	set(value):
		day = clamp(value, 1, Date._days_in_month(month, year))
		weekday = weekday # re-trigger weekday-setter
		emit_changed()

var weekday : int = 3:
	set(value):
		var unix_time = Time.get_unix_time_from_datetime_dict(self.as_dict())
		weekday = Time.get_date_dict_from_unix_time(unix_time).weekday

var _regex := RegEx.new()


func _init(dict := Time.get_date_dict_from_system()) -> void:
	#region ensure dict is a valid date dict
	assert("year" in dict.keys())
	assert("month" in dict.keys())
	assert("day" in dict.keys())

	assert(dict.year is int)

	assert(dict.month is int)
	assert(dict.month in range(1, 13))

	assert(dict.day is int)
	assert(dict.day in range(1, Date._days_in_month(dict.month, dict.year) + 1))
	#endregion

	year = dict.year
	month = dict.month
	day = dict.day

	_regex.compile("(\\[[^\\[]*\\])|(\\\\)?(Mo|MM?M?M?|Do|DD|ddd?d?|do?|YYYY|YY|.)")


func add_days(shift: int) -> Date:
	if shift == 0:
		return self

	var new_day = day + shift
	var new_month = month
	var new_year = year

	var days_in_current_month = Date._days_in_month(new_month, new_year)
	while not new_day in range(1, days_in_current_month + 1):
		if shift > 0:
			new_month += 1
			if new_month > 12:
				new_month = 1
				new_year += 1
			new_day -= days_in_current_month
			days_in_current_month = Date._days_in_month(new_month, new_year)
		else:
			new_month -= 1
			if new_month < 1:
				new_month = 12
				new_year -= 1
			days_in_current_month = Date._days_in_month(new_month, new_year)
			new_day += days_in_current_month

	return Date.new({
		"year": new_year,
		"month": new_month,
		"day": new_day,
	})


func add_months(shift: int) -> Date:
	if shift == 0:
		return self

	var new_year = year
	var new_month = month + shift

	while not new_month in range(1, 13):
		new_year += sign(shift)
		new_month -= 12 * sign(shift)

	return Date.new({
		"year": new_year,
		"month": new_month,
		"day": min(day, Date._days_in_month(new_month, new_year))
	})


func as_dict() -> Dictionary:
	return {
		"year": year,
		"month": month,
		"day": day,
		"weekday": weekday
	}


func as_string() -> String:
	return format("YYYY-MM-DD")


static func from_string(date_string: String) -> Date:
	var parts := date_string.split("-")
	var new_year = int(parts[0])
	var new_month = int(parts[1])
	var new_day = int(parts[2])

	return Date.new({
		"year": new_year,
		"month": new_month,
		"day": min(new_day, Date._days_in_month(new_month, new_year))
	})


func day_difference_to(date : Date) -> int:
	var t1 := Time.get_unix_time_from_datetime_dict(self.as_dict())
	var t2 := Time.get_unix_time_from_datetime_dict(date.as_dict())
	return floor(t1-t2) / 60 / 60 / 24


func equals(date: Date) -> bool:
	return (self.day_difference_to(date) == 0)


func is_weekend_day() -> bool:
	return self.weekday == 0 or self.weekday == 6


func format(format_string: String) -> String:
	var output := ""

	for unit in _regex.search_all(format_string):
		match unit.get_string():
			# Year:
			"YY":
				output += str(year).right(2)
			"YYYY":
				output += "%04d" % year
			# Month:
			"M":
				output += str(month)
			"Mo":
				output += Date._to_ordinal(month)
			"MM":
				output += "%02d" % month
			"MMM":
				output += _MONTH_NAMES[month - 1].left(3)
			"MMMM":
				output += _MONTH_NAMES[month - 1]
			# Day of Month:
			"D":
				output += str(day)
			"Do":
				output += Date._to_ordinal(day)
			"DD":
				output += "%02d" % day
			# Day of Week:
			"d":
				output += str(weekday)
			"do":
				output += Date._to_ordinal(weekday)
			"dd":
				output += _DAY_NAMES[weekday - 1].left(2)
			"ddd":
				output += _DAY_NAMES[weekday - 1].left(3)
			"dddd":
				output += _DAY_NAMES[weekday - 1]
			_:
				output += unit.get_string()

	return output


static func _to_ordinal(n: int) -> String:
	assert(n >= 0)

	var suffix : String

	if (n % 100) in [11, 12, 13]:
		suffix = "th"
	else:
		suffix = ["th", "st", "nd", "rd", "th"][min(n % 10, 4)]

	return str(n) + suffix


static func _days_in_month(month_: int, year_: int) -> int:
	assert(month_ in range(1, 13))

	if month_ == 2 and _is_leap_year(year_):
		return 29
	return _DAYS_IN_MONTH[month_]


static func _is_leap_year(year_: int) -> bool:
	return !(year_ % 4) and not (!(year_ % 100) and (year_ % 400))
