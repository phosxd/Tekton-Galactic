class_name TileGrid extends Node2D
@export var velocity := Vector2(0,0)
var mass:float = 0.0
var center_of_mass := Vector2(0,0)

signal tile_added(tile:TileGridTile)
signal tile_removed(tile:TileGridTile)


func _ready() -> void:
	_calculate_mass()



# Utility.
# --------
func get_center() -> Vector2: ## Gets center of the Grid, based on center of mass.
	return self.center_of_mass-self.position


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




func tile_collided(first:TileGridTile, second:TileGridTile) -> void:
	var first_grid = first.get_grid()
	var second_grid = second.get_grid()
	if not first_grid || not second_grid: return
	if first_grid == second_grid: return
	first_grid.velocity.x = MathUtils.resolve_solid_collision(first_grid.velocity.x, second_grid.velocity.x, first_grid.mass, second_grid.mass)
	first_grid.velocity.y = MathUtils.resolve_solid_collision(first_grid.velocity.y, second_grid.velocity.y, first_grid.mass, second_grid.mass)




func _on_tiles_child_entered_tree(node:Node) -> void:
	if node is not TileGridTile: return
	_calculate_mass()
	node.while_overlapping.connect(tile_collided.bind(node))
	tile_added.emit(node)

func _on_tiles_child_exiting_tree(node:Node) -> void:
	if node is not TileGridTile: return
	_calculate_mass()
	tile_removed.emit(node)
