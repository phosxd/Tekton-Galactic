extends CanvasLayer


func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file('res://CORE/Game Scenes/World/World.tscn')
