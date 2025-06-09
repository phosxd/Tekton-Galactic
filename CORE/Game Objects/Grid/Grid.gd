class_name TileGrid extends Node2D
@export var velocity := Vector2(0,0)
var last_velocity := velocity
var mass:float = 0.0
var center_of_mass := Vector2(0,0)

signal tile_added(tile:TileGridTile)
signal tile_removed(tile:TileGridTile)


func _ready() -> void:
	pass


func _process(_delta:float) -> void:
	last_velocity = velocity



# Utility.
# --------
func get_center() -> Vector2: ## Gets center of the Grid, based on center of mass.
	return self.center_of_mass + self.position


# Internal Utility.
# -----------------
func _calculate_mass() -> void:
	var total_position := Vector2(0,0)
	var total_mass:float = 0
	var count := 0
	for child in $Tiles.get_children():
		if child is not TileGridTile: continue
		total_position += child.position
		total_mass += child.mass
		count += 1
	center_of_mass = total_position/count
	mass = total_mass




func tile_collided(second:TileGridTile, first:TileGridTile) -> void:
	var first_grid = first.get_grid()
	var second_grid = second.get_grid()
	if not first_grid || not second_grid: return
	if first_grid == second_grid: return
	second.dont_collide_with_this_frame.append(first)
	var results_x:Vector2 = MathUtils.transfer_momentum(first_grid.last_velocity.x, second_grid.last_velocity.x, first_grid.mass, second_grid.mass)
	var results_y:Vector2 = MathUtils.transfer_momentum(first_grid.last_velocity.y, second_grid.last_velocity.y, first_grid.mass, second_grid.mass)
	var direction:Vector2 = ((first.Shape.get_rect().get_center()+first.position) - (second.Shape.get_rect().get_center()+second.position))
	var separation_vector:Vector2 = Vector2(direction.normalized()/500)
	first_grid.position -= separation_vector
	second_grid.position += separation_vector
	first_grid.velocity = Vector2(results_x.x, results_y.x)
	second_grid.velocity = Vector2(results_x.y, results_y.y)
	



func _on_tiles_child_entered_tree(node:Node) -> void:
	if node is not TileGridTile: return
	_calculate_mass()
	node.while_overlapping.connect(tile_collided.bind(node))
	tile_added.emit(node)

func _on_tiles_child_exiting_tree(node:Node) -> void:
	if node is not TileGridTile: return
	_calculate_mass()
	tile_removed.emit(node)
