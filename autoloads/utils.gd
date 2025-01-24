extends Node


func get_exported_properties(node: Node) -> Dictionary:
	var exported_properties := {}

	var current_group := "no_group"
	var current_group_prefix := ""
	for property in node.get_property_list():
		if property.usage & PROPERTY_USAGE_GROUP:
			current_group = property.name
			current_group_prefix = property.hint_string
		elif property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			if not property.name.begins_with(current_group_prefix):
				current_group = "no_group"
				current_group_prefix = ""

			if property.usage & PROPERTY_USAGE_STORAGE:
				if not exported_properties.has(current_group):
					exported_properties[current_group] = []

				exported_properties[current_group].append(property.name)

	return exported_properties
