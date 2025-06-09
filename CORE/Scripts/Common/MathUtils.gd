class_name MathUtils


static func transfer_range_of_value(origin:Vector2, target:Vector2, value:float) -> float:
	return (target.x + (((value - origin.x) / (origin.y - origin.x)) * (target.y - target.x)))


static func transfer_momentum(first_velocity:float, second_velocity:float, first_mass:float, second_mass:float, gain:float=100) -> Vector2: ## Transfers momentum based on mass and velocity. Returns new velocities for `first` and `second`.
	var first_result:float = first_velocity - ((first_velocity-second_velocity) / first_mass)
	var second_result:float = second_velocity - ((second_velocity-first_velocity) / second_mass)
	return Vector2(first_result, second_result)
