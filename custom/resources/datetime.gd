extends Resource
class_name DateTime

const month_names = [
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

const day_names = [
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


func _init(dict: Dictionary) -> void:
	# TODO: make sure dict is actually a date dict
	year = dict.year
	month = dict.month
	day = dict.day
	weekday = dict.weekday


# based on this: https://momentjs.com/docs/#/displaying/format/
func format(format_string: String) -> String:
	# TODO: turn this into an big regular expression?
	return format_string.replace(
		"\n", ""
	).replace(
		"\r", ""
	).replace(
		"YYYY", "%04d" % year
	).replace(
		"YY", str(year).right(2)
	).replace(
		"MMMM", month_names[month - 1]
	).replace(
		"MMM", month_names[month - 1].left(3)
	).replace(
		"MM", "%02d" % month
	).replace(
		"Mo", _to_ordinal(month)
	#).replace(
		#"M", str(date_dict.month) # FIXME: will replace the 'M' in 'May' when using 'MMM' or 'MMMM'
	).replace(
		"DD", "%02d" % day
	).replace(
		"Do", _to_ordinal(day)
	).replace(
		"D", str(day)
	).replace(
		"dddd", day_names[weekday - 1]
	).replace(
		"ddd", day_names[weekday - 1].left(3)
	).replace(
		"dd", day_names[weekday - 1].left(2)
	)


func _to_ordinal(n: int) -> String:
	var suffix : String

	if (n % 100) in [11, 12, 13]:
		suffix = "th"
	else:
		suffix = ["th", "st", "nd", "rd", "th"][min(n % 10, 4)]

	return str(n) + suffix
