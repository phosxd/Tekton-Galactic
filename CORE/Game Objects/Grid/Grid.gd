class_name TileGrid extends RigidBody2D
const scene = preload('res://CORE/Game Objects/Grid/Grid.tscn')

signal tile_added(tile:TileGridTile)
signal tile_removed(tile:TileGridTile)

var mouse_hovering:bool = false
var mouse_dragging:bool = false



static func construct() -> TileGrid:
	return scene.instantiate()


func _ready() -> void:
	pass


func _process(_delta:float) -> void:
	if mouse_hovering && Input.is_action_pressed('left_click'):
		mouse_dragging = true
	if not Input.is_action_pressed('left_click'):
		mouse_dragging = false
	if mouse_dragging:
		self.linear_velocity = -(self.get_center()-get_global_mouse_position())*2



# Utility.
# --------
func get_center() -> Vector2: ## Gets center of the Grid, based on center of mass.
	return self.center_of_mass + self.position


func add_tile(tile:TileGridTile) -> void: ## Adds the given tile to the grid, and recalculates grid mass.
	if tile.get_parent() == null: self.add_child(tile)
	else: tile.reparent(self)
	_calculate_mass()


func add_tiles(tiles:Array[TileGridTile]) -> void: ## Adds the given tiles to the grid, and recalculates grid mass. More efficient for adding multiple tiles at once.
	for tile:TileGridTile in tiles:
		if tile.get_parent() == null: self.add_child(tile)
		else: tile.reparent(self)
	_calculate_mass()


func destroy_tile(tile:TileGridTile) -> void: ## Destroys the given tile and recalculates grid mass.
	if tile.get_grid() != self: return # Does nothing if not a part of the same grid.
	tile.free()
	var tile_count:int = 0
	for child in self.get_children():
		if child is TileGridTile: tile_count += 1
	if tile_count == 0: self.queue_free()
	else: _calculate_mass()


func disconnect_tile(tile:TileGridTile) -> void: ## Disconnects the given tile and recalculates grid mass.
	if tile.get_grid() != self: return # Does nothing if not a part of the same grid.
	var new_grid := TileGrid.construct()
	new_grid.add_tile(tile)
	self.get_parent().add_child(new_grid)
	var tile_count:int = 0
	for child in self.get_children():
		if child is TileGridTile: tile_count += 1
	if tile_count == 0: self.queue_free()
	else: _calculate_mass()




# Internal Utility.
# -----------------
func _calculate_mass() -> void:
	var total_position := Vector2(0,0)
	var total_mass:float = 0
	var count:int = 0
	for child in self.get_children():
		if child is not TileGridTile: continue
		total_position += child.position
		total_mass += child.mass
		count += 1
	self.center_of_mass = total_position/count
	self.mass = total_mass


func _tile_area_entered(second:TileGridTile, first:TileGridTile) -> void:
	if [first,second] in PhysicsManager.Colliding_area_pairs: return
	if [second,first] in PhysicsManager.Colliding_area_pairs: return

	var first_grid:TileGrid = first.get_grid()
	var second_grid:TileGrid = second.get_grid()
	if not first_grid || not second_grid: return
	if first_grid == second_grid: return

	# Apply physics.
	var total_elasticity:float = (first.elasticity+second.elasticity) / 2.0
	var results_x:Vector2 = MathUtils.transfer_momentum(first_grid.last_velocity.x, second_grid.last_velocity.x, first_grid.mass, second_grid.mass, total_elasticity)
	var results_y:Vector2 = MathUtils.transfer_momentum(first_grid.last_velocity.y, second_grid.last_velocity.y, first_grid.mass, second_grid.mass, total_elasticity)
	first_grid.velocity = Vector2(results_x.x, results_y.x)
	second_grid.velocity = Vector2(results_x.y, results_y.y)




func _on_body_shape_entered(body_rid:RID, body:Node, body_shape_index:int, local_shape_index:int) -> void:
	if self.get_child_count()-1 < local_shape_index: return
	if self.get_child(local_shape_index) is not TileGridTile: return
	var tile:TileGridTile = self.get_child(local_shape_index)
	var total_energy = abs(((body.linear_velocity.x+body.linear_velocity.y)*body.mass))
	if tile.callback_can_destroy.call(total_energy):
		self.disconnect_tile.call_deferred((tile))




func _on_mouse_entered() -> void:
	mouse_hovering = true


func _on_mouse_exited() -> void:
	mouse_hovering = false
	if not Input.is_action_pressed('left_click'): mouse_dragging = false
