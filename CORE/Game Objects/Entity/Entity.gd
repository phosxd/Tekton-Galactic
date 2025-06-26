class_name Entity extends CharacterBody2D
## Base class for all game entities. Uses a component system to determine behavior and functionality.

var components:Array[Component] = []


func _init(components:Array[Component]) -> void:
	self.components = components
	for component:Component in self.components:
		component.init(self) # Assign component instance to this entity.


func _ready() -> void:
	pass
