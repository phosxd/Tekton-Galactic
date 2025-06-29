class_name GridGenerator_circle extends Node2D

@export var radius:int = 1
@export var tile_id:StringName
@export var linear_velocity:Vector2


func _ready() -> void:
	var grid := Grid.construct()
	self.get_parent().add_child.call_deferred((grid))

	grid.ready.connect(func() -> void:
		var tiles:Array[Tile] = []
		for i in range(radius * 2 + 1):
			for j in range(radius * 2 + 1):
				var x = i - radius
				var y = j - radius
				if x*x + y*y <= radius * radius:
					tiles.append(_make_tile(Vector2(x,y)))
		grid.add_tiles(tiles)
	)

	grid.position = self.position
	grid.linear_velocity = self.linear_velocity
	for child:Node in self.get_children():
		child.reparent(grid)
	self.queue_free()


func _make_tile(position:Vector2) -> Tile:
	var tile_data = SandboxManager.get_tile(tile_id).data
	var tile := Tile.construct(tile_data)
	tile.position = position
	return tile
