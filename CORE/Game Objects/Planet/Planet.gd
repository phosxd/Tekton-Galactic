class_name Planet extends Grid

@export var radius:int = 1
@export var hollow_radius:int = 0
@export var tile_id:String


var mass:float = 0
var center_of_mass := Vector2(0,0)
@export var linear_velocity := Vector2(0, 0)
@export var angular_velocity:float = 0



func _ready() -> void:
	var tiles:Array[Tile] = []
	for i in range(radius * 2 + 1):
		for j in range(radius * 2 + 1):
			var x = i - radius
			var y = j - radius
			var distance_from_center = x*x + y*y
			if distance_from_center <= radius * radius && distance_from_center >= hollow_radius * hollow_radius:
				tiles.append(_make_tile(Vector2(x,y)))
	self.add_tiles(tiles)


func _physics_process(delta:float) -> void:
	self.position += self.linear_velocity*delta
	self.rotate(self.angular_velocity*delta)


func _make_tile(position:Vector2) -> Tile:
	var tile_data = SandboxManager.get_tile(tile_id).data
	var tile := Tile.construct(tile_data)
	tile.position = position
	return tile
