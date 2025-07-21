class_name World extends Node2D

const G:float = 0.001/100


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
			second.apply_force(MathUtils.calculate_gravitational_force(
				World.G,
				first.get_center(),
				second.get_center(),
				first.mass,
				second.mass
			))

		for second:Entity in $Entities.get_children():
			if not is_instance_valid(second): continue
			second.apply_force(MathUtils.calculate_gravitational_force(
				World.G,
				first.get_center(),
				second.position,
				first.mass,
				second.mass
			))
