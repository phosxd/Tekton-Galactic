class_name TileGridTile extends Area2D
var mass:float = 1.0
var elasticity:float = 0.0
var dont_collide_with_this_frame:Array[Area2D] = []
var colliding_with:Array[Area2D] = []
@onready var Shape:Shape2D = %'Collision Shape'.shape

signal while_overlapping(area:Area2D)



func get_grid():
	var grandparent = $'../../'
	return grandparent if grandparent is TileGrid else null


func get_center() -> Vector2:
	return Shape.get_rect().get_center() + self.position



func _process(delta:float) -> void:
	dont_collide_with_this_frame.clear()




func _on_area_entered(area:Area2D) -> void:
	colliding_with.append(area)
	if area in dont_collide_with_this_frame: return
	while_overlapping.emit(area)


func _on_area_exited(area:Area2D) -> void:
	colliding_with.erase(area)
