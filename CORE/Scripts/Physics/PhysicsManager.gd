class_name PhysicsManager


const Gravity:float = 0.001 ## Gravity constant.
static var Colliding_area_pairs:Array[Array] ## All pairs of `Area2D`s that are currently colliding. Used to prevent unexpected duplicated collisions.


static func add_colliding_area_pair(a:Area2D, b:Area2D) -> void:
	Colliding_area_pairs.append([a,b])
static func remove_colliding_area_pair(a:Area2D, b:Area2D) -> void:
	Colliding_area_pairs.erase([a,b])
	Colliding_area_pairs.erase([b,a])
