class_name TileGridTile extends CollisionShape2D
const scene = preload('res://CORE/Game Objects/Tile/Tile.tscn')
var mass:float
var elasticity:float


static func construct() -> TileGridTile:
	return scene.instantiate()


func _init(mass:float=10.0, elasticity:float=0.05) -> void:
	self.mass = mass
	self.elasticity = elasticity
	


func get_grid():
	var parent = $'../'
	return parent if parent is TileGrid else null



# Callbacks.
# ----------
