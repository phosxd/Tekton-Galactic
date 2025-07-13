class_name GridGenerator_square extends Node2D

@export var size := Vector2(1,1)
@export var tile_id:StringName
@export var linear_velocity:Vector2


func _ready() -> void:
	var grid := Grid.construct()
	grid.ready.connect(func() -> void:
		var tiles:Array[Tile] = []
		for x in range(size.x):
			for y in range(size.y):
				tiles.append(_make_tile(Vector2(x,y)))
		grid.add_tiles(tiles)
	)
	grid.position = self.position
	grid.linear_velocity = self.linear_velocity
	for child:Node in self.get_children():
		child.reparent(grid)
	self.get_parent().add_child.call_deferred(grid)
	self.queue_free.call_deferred()


func _make_tile(position:Vector2) -> Tile:
	var tile_data = SandboxManager.get_tile(tile_id).data
	var tile := Tile.construct(tile_data)
	tile.position = position
	return tile
