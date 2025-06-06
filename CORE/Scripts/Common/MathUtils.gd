extends Node




# Rectangle utilities.
# --------------------
func is_overlapping(pos_a:Vector2, size_a:Vector2, pos_b:Vector2, size_b:Vector2) -> bool: ## Returns true if the boxes are overlapping.
	return (
		abs(pos_a.x - pos_b.x) * 2 < (size_a.x + size_b.x) and
		abs(pos_a.y - pos_b.y) * 2 < (size_a.y + size_b.y)
	)


func get_separation_vector(pos_a, size_a, pos_b, size_b):
	var dx = (pos_b.x - pos_a.x)
	var px = (size_a.x + size_b.x)/2 - abs(dx)

	var dy = (pos_b.y - pos_a.y)
	var py = (size_a.y + size_b.y)/2 - abs(dy)

	if px < py:
		return Vector2(sign(dx) * px, 0)
	else:
		return Vector2(0, sign(dy) * py)


func resolve_inelastic_bounce(first_velocity:float, second_velocity:float, first_mass:float, second_mass:float, elasticity:float) -> float:
	return ((first_mass - elasticity * second_mass) * first_velocity + (1 + elasticity) * second_mass * second_velocity) / (first_mass + second_mass)
