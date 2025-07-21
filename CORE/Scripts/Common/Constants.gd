class_name Constants

const directions:Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const directions_dictionary:Dictionary[String,Vector2i] = {
	'up': Vector2i.UP,
	'down': Vector2i.DOWN,
	'left': Vector2i.LEFT,
	'right': Vector2i.RIGHT,
}
enum collision_layers {
	PHYSICS_OBJECTS,
}
const collision_layers_dictionary:Dictionary[String, collision_layers] = {
	'physics_objects': collision_layers.PHYSICS_OBJECTS
}
