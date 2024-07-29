@tool
extends EditorPlugin

var _export_plugin : AutoExporter


func _enter_tree() -> void:
	_export_plugin = AutoExporter.new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null


class AutoExporter extends EditorExportPlugin:
	var _original_project_setting : String


	func _get_name() -> String:
		return "AutoExporter"


	func _export_begin(features : PackedStringArray, is_debug : bool, path : String, flags : int):
		if not _is_git_repository():
			return

		var version := "v%s, %s–%s" % [
			_get_git_commit_count(),
			_get_git_branch_name(),
			_get_git_commit_hash()
		]

		if not _is_working_tree_clean():
			version += ", dirty"

		_original_project_setting = ProjectSettings.get("application/config/version")

		if _original_project_setting:
			version = "%s (%s)" % [_original_project_setting, version]

		ProjectSettings.set("application/config/version", version)
		ProjectSettings.save()


	func _is_git_repository() -> bool:
		var output := []
		OS.execute("git", ["rev-parse", "--is-inside-work-tree"], output)
		if output[0].is_empty():
			return false
		return true


	func _get_git_branch_name() -> String:
		var output := []
		OS.execute("git", ["rev-parse", "--abbrev-ref", "HEAD"], output)
		if output[0].is_empty():
			return ""
		return output[0].trim_suffix("\n")


	func _get_git_commit_count() -> String:
		var output := []
		OS.execute("git", ["rev-list", "--count", "HEAD"], output)
		if output[0].is_empty():
			return ""
		return output[0].trim_suffix("\n")


	func _get_git_commit_hash() -> String:
		var output := []
		OS.execute("git", ["rev-parse", "--short", "HEAD"], output)
		if output[0].is_empty():
			return ""
		return output[0].trim_suffix("\n")


	func _is_working_tree_clean() -> bool:
		var output := []
		OS.execute("git", ["status", "--short"], output)
		if output[0].is_empty():
			return true
		return false


	func _export_end() -> void:
		ProjectSettings.set("application/config/version", _original_project_setting)
		ProjectSettings.save()
