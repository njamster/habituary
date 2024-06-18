extends Resource
class_name Date

const _MONTH_NAMES : Array[String] = [
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"Juli",
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

var year : int
var month : int
var day : int
var weekday : int

var _tokens := {}
var _regex := RegEx.new()


func _init(dict: Dictionary) -> void:
	#region ensure dict is a valid date dict
	assert(dict.keys() == ["year", "month", "day", "weekday"])

	assert(dict.year is int)

	assert(dict.month is int)
	assert(dict.month in range(1, 13))

	assert(dict.day is int)
	assert(dict.day in range(1, Date._days_in_month(dict.month, dict.year) + 1))

	assert(dict.weekday is int)
	assert(dict.weekday in range(0, 7))
	#endregion

	year = dict.year
	month = dict.month
	day = dict.day
	weekday = dict.weekday

	_tokens = {
		# Year:
		"YY":    func(): return str(year).right(2),
		"YYYY":  func(): return "%04d" % year,
		# Month:
		"M":     func(): return str(month),
		"Mo":    func(): return Date._to_ordinal(month),
		"MM":    func(): return "%02d" % month,
		"MMM":   func(): return _MONTH_NAMES[month - 1].left(3),
		"MMMM":  func(): return _MONTH_NAMES[month - 1],
		# Day of Month:
		"D":     func(): return str(day),
		"Do":    func(): return Date._to_ordinal(day),
		"DD":    func(): return "%02d" % day,
		# Day of Week:
		"d":     func(): return weekday,
		"do":    func(): return Date._to_ordinal(weekday),
		"dd":    func(): return _DAY_NAMES[weekday - 1].left(2),
		"ddd":   func(): return _DAY_NAMES[weekday - 1].left(3),
		"dddd":  func(): return _DAY_NAMES[weekday - 1],
	}

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
		"weekday": wrapi(weekday + shift, 0, 7)
	})


func as_dict() -> Dictionary:
	return {
		"year": year,
		"month": month,
		"day": day,
		"weekday": weekday
	}


func day_difference(to : Date) -> int:
	var t1 := Time.get_unix_time_from_datetime_dict(self.as_dict())
	var t2 := Time.get_unix_time_from_datetime_dict(to.as_dict())
	return (t1-t2) / 60.0 / 60.0 / 24.0


func format(format_string: String) -> String:
	var output := ""

	for unit in _regex.search_all(format_string):
		var string := unit.get_string()
		if string in _tokens:
			output += _tokens[string].call()
		else:
			output += string

	return output


func is_today() -> bool:
	var date_dict := Time.get_date_dict_from_system()
	return date_dict.year == self.year and \
		date_dict.month == self.month and \
		date_dict.day == self.day


func is_past() -> bool:
	var date_dict := Time.get_date_dict_from_system()
	return date_dict.year > self.year or \
		date_dict.year == self.year and date_dict.month > self.month or \
		date_dict.year == self.year and date_dict.month == self.month and date_dict.day > self.day


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
