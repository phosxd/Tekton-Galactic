class_name TileGridTile extends Area2D
var mass:float = 1.0

signal while_overlapping(area:Area2D)


func get_grid():
	var grandparent = $'../../'
	return grandparent if grandparent is TileGrid else null


func _process(delta:float) -> void:
	for area:Area2D in get_overlapping_areas():
		while_overlapping.emit(area)
