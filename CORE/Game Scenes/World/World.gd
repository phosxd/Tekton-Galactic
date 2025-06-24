class_name World extends Node2D


func _process(_delta:float) -> void:
	process_grids()



func process_grids() -> void:
	apply_gravity_on_grids()
	for child in $Grids.get_children():
		var marker := ColorRect.new()
		marker.color = Color(1, 1, 1, 0.05)
		marker.size = Vector2(0.5, 0.5)
		marker.position = child.get_center()
		self.get_tree().create_timer(4000).timeout.connect(func() -> void:
			marker.queue_free()
		)
		self.add_child(marker)


func apply_gravity_on_grids() -> void: ## Calculates gravitational force for every grid.
	var calculated_pairs:Array[Array] = [] ## Stores all pairs that have been calculated. Used to prevent unnecessary recalculation.
	for first:TileGrid in $Grids.get_children():
		for second:TileGrid in $Grids.get_children(): 
			if [second,first] in calculated_pairs: continue # Skip if this pair has already been calculated.
			if first == second: continue # Skip if first & second are the same object.
			if first.get_colliding_bodies().size() > 0: continue # Skip if any part of the first grid is touching the second grid.
			var direction:Vector2 = second.get_center() - first.get_center()
			var distance_squared:float = direction.length_squared()
			var force:float = (PhysicsManager.Gravity * (first.mass*second.mass)/distance_squared)
			var force_vector = direction.normalized() * force
			first.linear_velocity += force_vector/first.mass # Apply to force to first grid.
			second.linear_velocity -= force_vector/second.mass # Apply force to second grid.
			calculated_pairs.append([first,second]) # Remember pair, to prevent recalculation.
