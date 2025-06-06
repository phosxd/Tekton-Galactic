class_name TileGridTile extends Area2D
var mass:float = 1.0


func get_grid():
	var grandparent = $'../../'
	return grandparent if grandparent is TileGrid else null



func _on_area_entered(area:Area2D) -> void:
	pass
