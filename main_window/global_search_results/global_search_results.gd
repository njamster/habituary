extends VBoxContainer


func search() -> void:
	# remove previous results (if there are any)
	for child in get_children():
		child.queue_free()

	# reverse key order: future dates first, past dates last
	var cache_keys := Cache.data.keys()
	cache_keys.reverse()

	for key in cache_keys:
		for line in Cache.data[key].content:
			if line.contains(Settings.search_query):
				var label := Label.new()
				label.text = "%s: %s" % [key, line]
				add_child(label)

	if get_child_count() == 0:
		var no_hit_message := Label.new()
		no_hit_message.text = "No matching to-dos found. :("
		add_child(no_hit_message)

	self.show()
