class_name MathUtils

# Rectangle utilities.
# --------------------
static func is_overlapping(pos_a:Vector2, size_a:Vector2, pos_b:Vector2, size_b:Vector2) -> bool: ## Returns true if the boxes are overlapping.
	return (
		abs(pos_a.x - pos_b.x) * 2 < (size_a.x + size_b.x) and
		abs(pos_a.y - pos_b.y) * 2 < (size_a.y + size_b.y)
	)


static func get_separation_vector(pos_a:Vector2, size_a:Vector2, pos_b:Vector2, size_b:Vector2) -> Vector2:
	var dx = (pos_b.x - pos_a.x)
	var px = (size_a.x + size_b.x)/2 - abs(dx)

	var dy = (pos_b.y - pos_a.y)
	var py = (size_a.y + size_b.y)/2 - abs(dy)

	if px < py:
		return Vector2(sign(dx) * px, 0)
	else:
		return Vector2(0, sign(dy) * py)


static func resolve_collision(first_velocity:float, second_velocity:float, first_mass:float, second_mass:float) -> float: ## Resolves 1D collision between 2 objects. Returns new velocity.
	#return first_velocity
	var result:float = first_velocity - ((first_velocity-second_velocity) / (first_mass*second_mass))
	return result
