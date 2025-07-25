class_name TileMMI extends MultiMeshInstance2D

const empty_transform := Transform2D(0, Vector2.ZERO, 0, Vector2(999999,999999))

var instances:Array[Vector2i] = []
var empty_instance_indices:Array[int] = []


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
	var instance_index:int
	var instance_identifier:Vector2i = Vector2i(transform.get_origin())
	# Reuse empty instances if possible. Otherwise, append new.
	if empty_instance_indices.size() > 0:
		instance_index = empty_instance_indices.pop_at(0)
		instances[instance_index] = instance_identifier
	else:
		instance_index = instances.size()
		instances.append(instance_identifier)
		self.multimesh.instance_count += 1
	# Set instance transform.
	self.multimesh.set_instance_transform_2d.call_deferred(instance_index, Transform2D(transform))


func remove_tile(position:Vector2i) -> void:
	var index:int = instances.find(position)
	if index == -1: return
	empty_instance_indices.append(index)
	self.multimesh.set_instance_transform_2d(index, empty_transform)
