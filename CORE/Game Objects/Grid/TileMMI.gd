class_name TileMMI extends MultiMeshInstance2D

const empty_transform := Transform2D(0, Vector2.ZERO, 0, Vector2(999999,999999))

var instances:Array[Vector2i] = []


func _init(texture:Texture2D, texture_filter:CanvasItem.TextureFilter) -> void:
	self.texture = texture
	self.texture_filter = texture_filter
	var new_multimesh := MultiMesh.new()
	var new_mesh := QuadMesh.new()
	new_mesh.size = texture.get_size()
	new_mesh.size.y = -new_mesh.size.y
	new_multimesh.mesh = new_mesh
	self.multimesh = new_multimesh


func add_tile(transform:Transform2D) -> void:
	instances.append(Vector2i(transform.get_origin()))
	self.multimesh.instance_count += 1
	self.multimesh.set_instance_transform_2d.call_deferred(instances.size()-1, Transform2D(transform))


func remove_tile(position:Vector2i) -> void:
	var index:int = instances.find(position)
	if index == -1: return
	self.multimesh.set_instance_transform_2d(index, empty_transform)
