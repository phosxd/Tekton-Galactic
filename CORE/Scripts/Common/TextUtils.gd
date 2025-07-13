class_name TextUtils


static func remove_file_extension(text:String) -> String: ## Removes the file extension at the end of a file name.
	var split_text:PackedStringArray = text.split('.')
	if split_text.size() > 1:
		split_text.resize(split_text.size()-1)
	return '.'.join(split_text)
