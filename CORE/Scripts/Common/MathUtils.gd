class_name MathUtils


static func transfer_range_of_value(origin:Vector2, target:Vector2, value:float) -> float: ## Linear interpolation.
	return (target.x + (((value - origin.x) / (origin.y - origin.x)) * (target.y - target.x)))


static func limit_vector2_value(origin:Vector2, maximum:Vector2) -> Vector2: ## Limits the values of `origin`. Also applies to negative numbers.
	var result := Vector2(origin)
	if origin.x > maximum.x:
		result.x = maximum.x
	if origin.y > maximum.y:
		result.y = maximum.y
	if origin.x < -maximum.x:
		result.x = -maximum.x
	if origin.y < -maximum.y:
		result.y = -maximum.y

	return result


static func calculate_gravitational_force(g:float, first_position:Vector2, second_position:Vector2, first_mass:float, second_mass:float) -> Vector2:
	# Get distance.
	var direction:Vector2 = second_position - first_position
	var distance_squared:float = direction.length_squared()
	# Calculate gravitational force.
	var force:float = (g * (first_mass*second_mass)/distance_squared)
	var force_vector = direction.normalized() * force # Convert to vector.
	# Return zero force if NAN.
	if is_nan(force_vector.x) || is_nan(force_vector.y):
		return Vector2.ZERO
	# Return finalized force vector.
	return -force_vector


static func transfer_momentum(first_velocity:float, second_velocity:float, first_mass:float, second_mass:float, restitution:float=1) -> Vector2: ## Transfers momentum based on mass and velocity. Returns new velocities for `first` and `second`.
	#var first_result:float = (first_velocity - (((first_velocity-second_velocity)*(first_mass)) / (first_mass)))
	#var second_result:float = (second_velocity - (((second_velocity-first_velocity)*(second_mass)) / (second_mass)))
	var total_mass:float = first_mass+second_mass
	var first_result = ((first_mass-restitution*second_mass) / total_mass) * first_velocity + ((1+restitution)*second_mass/total_mass) * second_velocity
	var second_result = ((1+restitution) * first_mass/total_mass) * first_velocity + ((second_mass-restitution*first_mass) / total_mass) * second_velocity
	return Vector2(first_result, second_result)
