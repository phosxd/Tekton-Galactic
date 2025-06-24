class_name FileUtils


static func open_file_as_json(filepath:String):
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file: return
	var json_data = JSON.parse_string(file.get_as_text())
	return json_data
