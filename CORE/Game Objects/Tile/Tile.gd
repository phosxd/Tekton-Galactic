class_name TileGridTile extends Area2D
var mass:float = 1.0
var dont_collide_with_this_frame:Array[Area2D] = []
@onready var Shape:Shape2D = %'Collision Shape'.shape

signal while_overlapping(area:Area2D)



func get_grid():
	var grandparent = $'../../'
	return grandparent if grandparent is TileGrid else null


func _process(delta:float) -> void:
	for area:Area2D in get_overlapping_areas():
		if area in dont_collide_with_this_frame: continue
		while_overlapping.emit(area)
	dont_collide_with_this_frame.clear()
