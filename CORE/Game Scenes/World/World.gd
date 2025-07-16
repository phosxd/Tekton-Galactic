class_name World extends Node2D

const G:float = 0.001


func _ready() -> void:
	var entity_data = SandboxManager.get_entity('core:player').data
	var entity := Entity.construct(entity_data)
	entity.position = Vector2(0,0)
	$Entities.add_child(entity)
	%Camera.position = Vector2(0,0)
	%Camera.reparent(entity)


func _process(_delta:float) -> void:
	apply_planetary_gravity()


func apply_planetary_gravity() -> void: ## Calculates gravitational force from planets on every Grid.
	for first:Grid in $Planets.get_children():
		if not is_instance_valid(first): continue
		if first.mass <= 0: continue
		for second:Grid in $Grids.get_children(): 
			if not is_instance_valid(second): continue
			var direction:Vector2 = second.get_center() - first.get_center()
			var distance_squared:float = direction.length_squared()
			var force:float = (World.G * (first.mass*second.mass)/distance_squared)
			var force_vector = direction.normalized() * force
			if is_nan(force_vector.x) || is_nan(force_vector.y): continue
			second.apply_force(-force_vector/second.mass)

		for second:Entity in $Entities.get_children():
			if not is_instance_valid(second): continue
			var direction:Vector2 = second.position - first.get_center()
			var distance_squared:float = direction.length_squared()
			var force:float = (World.G * (first.mass*second.mass)/distance_squared)
			var force_vector = direction.normalized() * force
			if is_nan(force_vector.x) || is_nan(force_vector.y): continue
			second.apply_force(-force_vector/second.mass)
