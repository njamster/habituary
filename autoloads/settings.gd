extends Node

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

var date_format_show := "dddd, MMMM Do YYYY"
var date_format_save := "YYYY-MM-DD"

var home_path := OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")
var store_path := home_path + "/" + str(ProjectSettings.get("application/config/name")).to_lower()


# based on this: https://momentjs.com/docs/#/displaying/format/
func format_date(date_dict: Dictionary, format_string = date_format_save) -> String:
	# TODO: turn this into an big regular expression?
	return format_string.replace(
		"\n", ""
	).replace(
		"\r", ""
	).replace(
		"YYYY", "%04d" % date_dict.year
	).replace(
		"YY", str(date_dict.year).right(2)
	).replace(
		"MMMM", month_names[date_dict.month - 1]
	).replace(
		"MMM", month_names[date_dict.month - 1].left(3)
	).replace(
		"MM", "%02d" % date_dict.month
	).replace(
		"Mo", to_ordinal(date_dict.month)
	#).replace(
		#"M", str(date_dict.month) # FIXME: will replace the 'M' in 'May' when using 'MMM' or 'MMMM'
	).replace(
		"DD", "%02d" % date_dict.day
	).replace(
		"Do", to_ordinal(date_dict.day)
	).replace(
		"D", str(date_dict.day)
	).replace(
		"dddd", day_names[date_dict.weekday - 1]
	).replace(
		"ddd", day_names[date_dict.weekday - 1].left(3)
	).replace(
		"dd", day_names[date_dict.weekday - 1].left(2)
	)


func to_ordinal(n: int) -> String:
	var suffix : String

	if (n % 100) in [11, 12, 13]:
		suffix = "th"
	else:
		suffix = ["th", "st", "nd", "rd", "th"][min(n % 10, 4)]

	return str(n) + suffix
