class_name GridGenerator_square extends Node2D

@export var size := Vector2(1,1)
@export var tile_id:StringName
@export var linear_velocity:Vector2

var tile_data:Dictionary


func _ready() -> void:
	self.tile_data = SandboxManager.get_tile(self.tile_id).data

	var grid := Grid.construct()
	grid.ready.connect(func() -> void:
		for x in range(size.x):
			for y in range(size.y):
				grid.add_tile(_make_tile(Vector2(x,y)), false)
		grid._calculate_mass()
	)
	grid.position = self.position
	grid.linear_velocity = self.linear_velocity
	for child:Node in self.get_children():
		child.reparent(grid)
	self.get_parent().add_child.call_deferred(grid)
	self.queue_free.call_deferred()


func _make_tile(tile_position:Vector2) -> Tile:
	var tile := Tile.construct(tile_data)
	tile.position = tile_position
	return tile
