class_name Cursor extends Area2D


func _process(_delta:float) -> void:
	self.position = get_parent().get_local_mouse_position()
