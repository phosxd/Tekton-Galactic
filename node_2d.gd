extends Node2D

func _process(delta:float) -> void:
	if %Ray.is_colliding():
		var grid = %Ray.get_collider()
		if not grid: return
		if grid is not Grid: return
		grid._get_child_from_shape_idx(%Ray.get_collider_shape())
