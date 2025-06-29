class_name TilePartition extends Area2D
## Manages a group of `Tile`s for a `Grid`.

enum state {
	AWAKE,
	SLEEPING,
}

var members:Array[Tile] = []
var _current_state:state = state.AWAKE


func _init() -> void:
	pass


func add_member(tile:Tile) -> void: ## Add a `Tile` to the partition.
	members.append(tile)


func add_members(tiles:Array[Tile]) -> void: ## Add multiple `Tile`s to the partition.
	for tile:Tile in tiles:
		add_member(tile)


func wake() -> void: ## Put the parittion in AWAKE mode.
	if self._current_state == TilePartition.state.AWAKE: return
	self._current_state = TilePartition.state.AWAKE
	for tile:Tile in self.members:
		tile.wake()


func sleep() -> void: ## Put the partition in SLEEP mode.
	if self._current_state == TilePartition.state.SLEEPING: return
	self._current_state = TilePartition.state.SLEEPING
	for tile:Tile in self.members:
		tile.sleep()
