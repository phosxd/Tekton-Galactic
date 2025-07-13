extends Component
const name := 'shape'

var object
var normal_shape:Shape2D
var terrain_shape:Shape2D


func init(object) -> void:
	self.object = object
	if self.parameters.get('normal') == null: return
	normal_shape = SandboxManager.get_shape(self.parameters.normal.id)
	if not normal_shape: return
	self.parameters.terrain = self.parameters.get('terrain', self.parameters.normal)
	terrain_shape = SandboxManager.get_shape(self.parameters.terrain.id)

	# Apply the shape, if it exists.
	object.set_general_shape(normal_shape)

	# Connect signals for terrain shape.
	if object is Tile:
		object.neighbor_tile_update.connect(self.update_terrain_shape)
		for direction in Constants.directions:
			pass
			self.update_terrain_shape(direction)


func update_terrain_shape(tile_direction:Vector2i) -> void:
	var neighbors:Dictionary[String,Tile] = self.object.get_neighbors()
	var up = neighbors.up
	var down = neighbors.down
	var left = neighbors.left
	var right = neighbors.right
	if not up && down && left && not right:
		self.object.set_general_shape(terrain_shape, 0)
	elif not up && down && not left && right:
		self.object.set_general_shape(terrain_shape, -90)
	elif up && not down && left && not right:
		self.object.set_general_shape(terrain_shape, 90)
	elif up && not down && not left && right:
		self.object.set_general_shape(terrain_shape, 180)
	else:
		self.object.set_general_shape(normal_shape, 0)
