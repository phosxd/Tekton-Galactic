extends Component
const name := 'shape'

const square_polygon_points:Array[Vector2] = [
	Vector2(-0.5, -0.5),
	Vector2(0.5, -0.5),
	Vector2(0.5, 0.5),
	Vector2(-0.5, 0.5),
]

var object
var normal_shape:Shape2D
var slope_shape:Shape2D
var use_surface_polygon:bool


func init(object) -> void:
	self.object = object
	if self.parameters.get('normal') == null: return
	self.normal_shape = SandboxManager.get_shape(self.parameters.normal.id)
	if not normal_shape: return
	var slope_shape_id = self.parameters.get('slope', self.parameters.normal.id)
	self.slope_shape = SandboxManager.get_shape(slope_shape_id, normal_shape)
	self.use_surface_polygon = self.parameters.get('use_surface_polygon', false)

	# Apply the shape.
	self.object.set_main_shape(normal_shape)

	# Connect signals.
	if object is Tile:
		#if self.use_surface_polygon:
			#var new_shape := ConvexPolygonShape2D.new()
			#new_shape.points = generate_surface_polygon()
			#self.object.set_main_shape(new_shape)
		object.neighbor_tile_update.connect(self.update_shape)
		for direction in Constants.directions:
			self.update_shape(direction)


func update_shape(_tile_direction:Vector2i) -> void:
	self.object.set_main_shape(self.normal_shape, 0)
	if self.slope_shape != self.normal_shape:
		var neighbors:Dictionary[String,Tile] = self.object.get_neighbors()
		var up = neighbors.up
		var down = neighbors.down
		var left = neighbors.left
		var right = neighbors.right
		if not up && down && left && not right:
			self.object.set_main_shape(self.slope_shape, 0)
		elif not up && down && not left && right:
			self.object.set_main_shape(self.slope_shape, -90)
		elif up && not down && left && not right:
			self.object.set_main_shape(self.slope_shape, 90)
		elif up && not down && not left && right:
			self.object.set_main_shape(self.slope_shape, 180)
		else:
			self.object.set_main_shape(self.normal_shape, 0)


func generate_surface_polygon() -> PackedVector2Array:
	var points := PackedVector2Array()
	# Initialize polygon as a square.
	for vec:Vector2 in self.square_polygon_points:
		points.append(Vector2(vec)) # Append duplicated `Vector2`.
	# Make point positions global.
	var index:int = -1
	for point:Vector2 in points:
		index += 1
		points[index] += self.object.position
	# Manipulate points to face away from center of mass.
	var grid = self.object.get_grid()
	var surface_points:Array[Vector2] = [points[0], points[2]]
	var target_direction:Vector2 = grid.center_of_mass.direction_to(surface_points[0]-surface_points[1])

	return points
