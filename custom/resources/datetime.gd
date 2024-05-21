extends Resource
class_name DateTime

const month_names : Array[String] = [
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

const day_names : Array[String] = [
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
	"Sunday"
]

var year : int
var month : int
var day : int
var weekday : int

var _tokens := {}
var _regex := RegEx.new()


func _init(dict: Dictionary) -> void:
	# TODO: make sure dict is actually a date dict
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
		"Mo":    _to_ordinal(month),
		"MM":    "%02d" % month,
		"MMM":   month_names[month - 1].left(3),
		"MMMM":  month_names[month - 1],
		# Day of Month:
		"D":     str(day),
		"Do":    _to_ordinal(day),
		"DD":    "%02d" % day,
		# Day of Week:
		"d":     weekday,
		"do":    _to_ordinal(weekday),
		"dd":    day_names[weekday - 1].left(2),
		"ddd":   day_names[weekday - 1].left(3),
		"dddd":  day_names[weekday - 1],
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


func _to_ordinal(n: int) -> String:
	var suffix : String

	if (n % 100) in [11, 12, 13]:
		suffix = "th"
	else:
		suffix = ["th", "st", "nd", "rd", "th"][min(n % 10, 4)]

	return str(n) + suffix
