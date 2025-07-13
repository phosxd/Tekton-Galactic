class_name GridGenerator_circle extends Node2D

@export var radius:int = 1
@export var hollow_radius:int = 0
@export var tile_id:StringName
@export var linear_velocity:Vector2


func _ready() -> void:
	var grid := Grid.construct()
	grid.ready.connect(func() -> void:
		var tiles:Array[Tile] = []
		for i in range(radius * 2 + 1):
			for j in range(radius * 2 + 1):
				var x:int = i - radius
				var y:int = j - radius
				var is_tip = (x == -radius) or (x == radius) or (y == -radius) or (y == radius)
				if is_tip: continue
				if x*x + y*y < hollow_radius * hollow_radius: continue
				if x*x + y*y <= radius * radius:
					var tile_position := Vector2i(x,y)
					var new_tile:Tile
					new_tile = _make_tile(tile_position)
					tiles.append(new_tile)
		grid.add_tiles(tiles)
	)

	grid.position = self.position
	grid.linear_velocity = self.linear_velocity
	for child:Node in self.get_children():
		child.reparent(grid)
	self.get_parent().add_child.call_deferred(grid)
	self.queue_free.call_deferred()


func _make_tile(position:Vector2i) -> Tile:
	var tile_data = SandboxManager.get_tile(tile_id).data
	var tile := Tile.construct(tile_data)
	tile.position = Vector2(position)
	return tile
