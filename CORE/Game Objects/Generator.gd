class_name Generator extends Node2D

var time_between_batch:float = 0.1
var batch_size:int = 10
var components:Array[Component] = [] ## Generator's components.


static func construct(data:Dictionary) -> Generator:
	var new_generator := Generator.new()
	for key in data.COMPONENTS:
		var value = data.COMPONENTS[key]
		var new_component := Component.new()
		var component_script = SandboxManager.generator_components.get(key)
		if not component_script: component_script = SandboxManager.components.get(key)
		if not component_script: continue
		new_component.set_script(component_script)
		new_component.init_parameters(value)
		new_generator.components.append(new_component)

	return new_generator


func _ready() -> void:
	for component:Component in self.components:
		component.init.call_deferred(self) # Assign component instance to this generator.


func _process(_delta:float) -> void:
	pass
