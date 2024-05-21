extends Node

var date_format_show := "dddd, MMMM Do YYYY"
var date_format_save := "YYYY-MM-DD"

var home_path := OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")
var store_path := home_path + "/" + str(ProjectSettings.get("application/config/name")).to_lower()
