extends Node2D
const G := 0.05 #6.67*pow(10,-11)





func _process(delta:float) -> void:
	process_grids()



func process_grids() -> void:
	apply_gravity_on_grids()
	for child in $Grids.get_children():
		child.position += child.velocity


func apply_gravity_on_grids() -> void: # Calculates gravitational force for every grid.
	for first:TileGrid in $Grids.get_children():
		for second:TileGrid in $Grids.get_children():
			if first == second: continue
			var direction:Vector2 = second.get_center() - first.get_center()
			var distance_squared := (direction.x**2 + direction.y**2)
			var distance = sqrt(distance_squared)
			if distance < 10: continue
			var force:float = (G * first.mass * second.mass / (distance_squared))
			first.velocity -= ((force * direction / distance) / second.mass)
