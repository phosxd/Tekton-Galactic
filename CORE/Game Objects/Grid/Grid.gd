class_name Grid extends PhysicsBody2D
const scene = preload('res://CORE/Game Objects/Grid/Grid.tscn')

signal mass_updated
signal tile_added(tile:Tile)
signal tile_removed(tile:Tile)

var tiles:Dictionary[Vector2i,Tile] = {}
var partitions:Array[TilePartition] = []



static func construct() -> Grid:
	var new_grid:Grid = scene.instantiate()
	var cm_visualizer_texture = SandboxManager.get_texture('center_of_mass_visualizer')
	new_grid.get_node('%CM Visualizer').texture = cm_visualizer_texture
	new_grid.get_node('%CM Visualizer').scale = Vector2(Vector2.ONE/cm_visualizer_texture.get_size())

	return new_grid


func _process(_delta:float) -> void:
	pass



# Methods.
# --------
func get_center() -> Vector2: ## Gets center of the Grid, based on center of mass.
	return self.center_of_mass + self.position


func get_energy() -> float:
	return ((abs(self.linear_velocity.x)+abs(self.linear_velocity.y)) + abs(self.angular_velocity))


func get_tile(position:Vector2i): ## Returns the tile at the given position, if doesn't exist returns null.
	var tile = self.tiles.get(position)
	if not tile: return null
	return tile


func add_tile(tile:Tile, position:Vector2i, extra_operations:bool=true) -> bool: ## Adds the given tile to the grid. Recalculates grid mass if `extra_operations` is true. Returns `true` if succesfully added the tile.
	if not tile: return false
	tile.grid_position = position
	tile.position = Vector2(position)
	if tile.get_grid() == null:
		self.add_child(tile)
	else:
		tile.before_disconnected.emit()
		tile.get_grid().tiles.erase(tile.grid_position)
		tile.reparent(self)
		tile.after_disconnected.emit()
		tile.tile_update.emit()

	var current_tile = self.get_tile(tile.grid_position)
	if current_tile != null:
		self.destroy_tile(current_tile, false)

	self.tiles.set(tile.grid_position, tile)
	self.tile_added.emit(tile)

	if extra_operations:
		_calculate_mass()

	return true


func add_tiles(tiles:Array[Tile], positions:Array[Vector2i]) -> void: ## Adds the given tiles to the grid. Recalculates grid mass if `extra_operations` is true. More efficient for adding multiple tiles at once.
	_iterate_tiles(func(index:int, tile:Tile) -> bool:
		self.add_tile(tile, positions[index], false)
		return true
	,true, tiles)


func destroy_tile(tile:Tile, extra_operations:bool=true) -> bool: ## Destroys the given tile. Recalculates grid mass if `extra_operations` is true. Returns `true` if succesfully destroyed the tile.
	if not tile: return false
	if tile.get_grid() != self: return false

	tile.before_destroyed.emit()
	self.tiles.erase(tile.grid_position)
	tile.queue_free()
	tile.after_destroyed.emit()
	#tile.tile_update.emit()

	if extra_operations:
		_calculate()

	return true


func disconnect_tile(tile:Tile, extra_operations:bool=true) -> void: ## Disconnects the given tile. Recalculates grid mass if `extra_operations` is true.
	if tile.get_grid() != self: return # Does nothing if not a part of the same grid.
	var new_grid := Grid.construct()
	new_grid.position = self.position
	new_grid.rotation = self.rotation
	# Randomly disconnect neighboring tiles.
	for neighbor:Tile in tile.get_neighbors().values():
		if not neighbor: continue
		if randi_range(0,1) == 0: continue
		neighbor.before_disconnected.emit()
		new_grid.add_tile(neighbor, neighbor.grid_position)
		neighbor.after_disconnected.emit()
	tile.before_disconnected.emit()
	new_grid.add_tile(tile, tile.grid_position)
	self.get_parent().add_child(new_grid)
	tile.after_disconnected.emit()

	if extra_operations:
		_calculate()




# Internal Utility.
# -----------------
func _add_mmi(id:int, texture:Texture2D, texture_filter:CanvasItem.TextureFilter) -> TileMMI:
	var mmi := TileMMI.new(texture, texture_filter)
	mmi.name = str(id)
	%'Tile MMIs'.add_child(mmi)
	return mmi


func add_instance_to_mmi(id:int, texture:Texture2D, texture_filter:CanvasItem.TextureFilter, transform:Transform2D) -> bool:
	var mmi = %'Tile MMIs'.get_node_or_null(str(id))
	if not mmi:
		mmi = _add_mmi(id, texture, texture_filter)
	mmi.add_tile(transform)
	return true


func remove_instance_from_mmi(id:int, grid_position:Vector2i) -> bool:
	var mmi = %'Tile MMIs'.get_node_or_null(str(id))
	if not mmi: return false
	mmi.remove_tile(grid_position)
	return true


func _iterate_tiles(function=null, calculate_mass:bool=false, tiles_array_override=null) -> void: ## Efficiently iterates over each tile in the grid.
	var total_position := Vector2(0,0)
	var total_mass:float = 0
	var count:int = 0
	var tiles:Array[Tile]
	if tiles_array_override: tiles = tiles_array_override
	else: tiles = self.tiles.values()

	for tile:Tile in tiles:
		count += 1
		if function:
			if not function.call(count-1, tile) == true: continue
		if calculate_mass:
			total_position += tile.grid_position * tile.mass
			total_mass += tile.mass

	if calculate_mass:
		if total_mass <= 0: total_mass = 0.00001
		self.center_of_mass = total_position/total_mass
		self.mass = total_mass
		self.mass_updated.emit()


func _calculate_mass() -> void: ## Calculates the mass of the grid then stores the result.
	_iterate_tiles(null, true)


func _calculate() -> void:
	if not self: return

	var tile_count:int = 0
	for key in self.tiles:
		var value = self.tiles[key]
		if not value: self.tiles.erase(key)
		tile_count += 1
	if tile_count == 0:
		self.queue_free()
		return

	# Separate all structurally disconnected sections of the Grid.
	# Yeah so I couldn't find out why sometimes this function is called before the Grid is assigned a parent.
	# This check just ensures the game doesn't crash until I can find out how to prevent this.
	if self.get_parent() != null:
		var sections := _find_separate_sections()
		var section_index:int = -1
		for section:Array[Tile] in sections:
			section_index += 1
			if section_index == 0: continue
			if section.is_empty(): continue
			var section_grid := Grid.construct()
			self.get_parent().add_child(section_grid)
			section_grid.linear_velocity = self.linear_velocity
			section_grid.angular_velocity = self.angular_velocity
			if section.size() > 0:
				section_grid.position = self.position
				section_grid.rotation = self.rotation
			for tile:Tile in section:
				section_grid.add_tile(tile, tile.grid_position, false)
			section_grid._calculate_mass()
	else: print('hi')

	_calculate_mass()


func _find_separate_sections() -> Array[Array]:
	var sections:Array[Array] = []
	var passed_tiles:Dictionary[Tile,Variant] = {}
	for tile:Tile in self.tiles.values():
		if not tile: continue
		if tile.is_queued_for_deletion(): continue
		var neighbor_tiles = tile.get_neighbors().values()
		if neighbor_tiles.find(null) == -1: continue # Move on if the tile has all sides occupied.
		var result := _recursive_tile_search([], tile, passed_tiles)
		passed_tiles = result.passed_tiles
		if result.new_section.size() > 0:
			sections.append(result.new_section)
	print(sections.size())

	return sections


func _recursive_tile_search(section:Array, origin_tile:Tile, passed_tiles:Dictionary[Tile,Variant]) -> Dictionary:
	var tiles_to_check:Array[Tile] = [origin_tile]
	while not tiles_to_check.is_empty():
		var tile:Tile = tiles_to_check.pop_front()
		if not tile: continue
		if tile is not Tile: continue
		if not is_instance_valid(tile): continue
		if tile.is_queued_for_deletion(): continue
		if passed_tiles.has(tile): continue
		var neighbor_tiles = tile.get_neighbors().values()
		if neighbor_tiles.find(null) == -1: continue # Move on if the tile has all sides occupied.
		section.append(tile)
		passed_tiles.set(tile, null)
		for neighbor:Tile in neighbor_tiles:
			tiles_to_check.append(neighbor)

	return {
		'new_section': section,
		'passed_tiles': passed_tiles,
	}


func _resolve_collision(body:Grid, tile:Tile) -> void:
	var velocity = (body.get_energy() - self.get_energy())
	var incoming_energy = abs(0.5 * (velocity))
	if tile.can_destroy.call(incoming_energy):
		self.destroy_tile.call_deferred(tile)
	elif tile.can_disconnect.call(incoming_energy):
		self.disconnect_tile.call_deferred(tile)


func _get_child_from_shape_idx(shape_index:int):
	if shape_index > self.get_shape_owners().size()-1: return null
	var shape_owner_id:int = self.shape_find_owner(shape_index)
	if shape_owner_id not in self.get_shape_owners(): return null
	var shape_owner = self.shape_owner_get_owner(shape_owner_id)
	if shape_owner is not Node: return null
	return shape_owner




# Callbacks.
# ----------
func _on_mass_updated() -> void:
	%'CM Visualizer'.position = self.center_of_mass # Update position of visualizer.
	%'CM Visualizer'.move_to_front()


func _on_body_shape_entered(_body_rid:RID, body:Node, _body_shape_index:int, local_shape_index:int) -> void:
	var tile = _get_child_from_shape_idx(local_shape_index)
	if not tile: return
	if tile is not Tile: return
	if body is Grid:
		_resolve_collision(body, tile)
