class_name World extends Node2D

const G:float = 1000


func _process(_delta:float) -> void:
	apply_planetary_gravity()


func apply_planetary_gravity() -> void: ## Calculates gravitational force from planets on every Grid.
	for first:Planet in $Planets.get_children():
		for second:Grid in $Grids.get_children(): 
			var direction:Vector2 = second.get_center() - first.get_center()
			var distance_squared:float = direction.length_squared()
			var force:float = (World.G * (first.mass*second.mass)/distance_squared)
			var force_vector = direction.normalized() * force
			second.apply_force(-force_vector/second.mass)
			#second.linear_velocity -= force_vector/second.mass # Apply force to Grid.
