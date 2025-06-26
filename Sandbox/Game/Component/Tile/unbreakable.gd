extends TileComponent
const name := 'unbreakable'


func init(tile:TileGridTile) -> void:
	tile.callback_can_destroy = func(energy:float) -> bool:
		return false
