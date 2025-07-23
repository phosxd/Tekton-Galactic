class_name GridGenerator_square extends Node2D

@export var size := Vector2(1,1)
@export var tile_id:StringName
@export var linear_velocity:Vector2

var tile_data:Dictionary


func _ready() -> void:
	self.tile_data = SandboxManager.get_tile(self.tile_id).data
	var grid := Grid.construct()
	grid.ready.connect(func() -> void:
		var total_position := Vector2(0,0)
		var total_mass:float = 0
		var count:int = 0

		for x in range(size.x):
			for y in range(size.y):
				var new_tile:Tile
				new_tile = _make_tile()
				grid.add_tile(new_tile, Vector2i(x,y), false)
				total_position += Vector2(new_tile.grid_position)
				total_mass += new_tile.mass
				count += 1

		if total_mass <= 0: total_mass = 0.00001
		grid.center_of_mass = total_position/count
		grid.mass = total_mass
	)

	grid.position = self.position
	grid.linear_velocity = self.linear_velocity
	for child:Node in self.get_children():
		child.reparent(grid)
	self.get_parent().add_child.call_deferred(grid)
	self.queue_free.call_deferred()


func _make_tile() -> Tile:
	var tile := Tile.construct(tile_data)
	return tile
