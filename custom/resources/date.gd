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
	assert(dict.day in range(1, Date._days_in_month(dict.month, dict.year)))

	assert(dict.weekday is int)
	assert(dict.weekday in range(1, 8))
	#endregion

	year = dict.year
	month = dict.month
	day = dict.day
	weekday = dict.weekday

	_tokens = {
		# Year:
		"YY":    str(year).right(2),
		"YYYY": "%04d" % year,
		# Month:
		"M":     str(month),
		"Mo":    Date._to_ordinal(month),
		"MM":    "%02d" % month,
		"MMM":   _MONTH_NAMES[month - 1].left(3),
		"MMMM":  _MONTH_NAMES[month - 1],
		# Day of Month:
		"D":     str(day),
		"Do":    Date._to_ordinal(day),
		"DD":    "%02d" % day,
		# Day of Week:
		"d":     weekday,
		"do":    Date._to_ordinal(weekday),
		"dd":    _DAY_NAMES[weekday - 1].left(2),
		"ddd":   _DAY_NAMES[weekday - 1].left(3),
		"dddd":  _DAY_NAMES[weekday - 1],
	}

	_regex.compile("(\\[[^\\[]*\\])|(\\\\)?(Mo|MM?M?M?|Do|DD|ddd?d?|do?|YYYY|YY|.)")


func format(format_string: String) -> String:
	var output := ""

	for unit in _regex.search_all(format_string):
		var string := unit.get_string()
		if string in _tokens:
			output += _tokens[string]
		else:
			output += string

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
