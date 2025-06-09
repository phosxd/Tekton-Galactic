class_name MathUtils


static func transfer_range_of_value(origin:Vector2, target:Vector2, value:float) -> float:
	return (target.x + (((value - origin.x) / (origin.y - origin.x)) * (target.y - target.x)))


static func transfer_momentum(first_velocity:float, second_velocity:float, first_mass:float, second_mass:float, restitution:float=1) -> Vector2: ## Transfers momentum based on mass and velocity. Returns new velocities for `first` and `second`.
	#var first_result:float = (first_velocity - (((first_velocity-second_velocity)*(first_mass)) / (first_mass)))
	#var second_result:float = (second_velocity - (((second_velocity-first_velocity)*(second_mass)) / (second_mass)))
	var total_mass:float = first_mass+second_mass
	var first_result = ((first_mass-second_mass)/total_mass) * first_velocity + (2*second_mass/total_mass) * second_velocity
	var second_result = (2*first_mass/total_mass) * first_velocity + ((second_mass-first_mass)/total_mass) * second_velocity
	var new_v1 = ((first_mass - restitution * second_mass) / total_mass) * first_velocity + ((1 + restitution) * second_mass / total_mass) * second_velocity
	var new_v2 = ((1 + restitution) * first_mass / total_mass) * first_velocity + ((second_mass - restitution * first_mass) / total_mass) * second_velocity
	return Vector2(new_v1, new_v2)
