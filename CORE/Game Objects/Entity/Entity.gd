class_name Entity extends CharacterBody2D
## Base class for all game entities. Uses a component system to determine behavior and functionality.

var Components:Array[Component] = []


func _init(components:Array[Component]) -> void:
	Components = components
	for component:Component in Components:
		component.init(self) # Assign component instance to this entity.


func _ready() -> void:
	pass
