class_name GridGenerator_circle extends Node2D

@export var radius:int = 1
@export var tile_id:StringName
@export var smooth_surface:bool = false
@export var linear_velocity:Vector2


func _ready() -> void:
	var grid := Grid.construct()
	self.get_parent().add_child.call_deferred((grid))

	grid.ready.connect(func() -> void:
		var tiles:Array[Tile] = []
		for i in range(radius * 2 + 1):
			for j in range(radius * 2 + 1):
				var x:int = i - radius
				var y:int = j - radius
				#var distance = x*x + y*y
				#var is_edge = distance > (radius - 1) * (radius - 1) and distance <= radius * radius
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
	self.queue_free()


func _make_tile(position:Vector2i) -> Tile:
	var tile_data = SandboxManager.get_tile(tile_id).data
	var tile := Tile.construct(tile_data)
	tile.position = Vector2(position)
	return tile

func _make_edge_tile(position:Vector2) -> Tile:
	var tile_data = SandboxManager.get_tile('core:unobtainium').data
	var tile := Tile.construct(tile_data)
	tile.position = position
	return tile
