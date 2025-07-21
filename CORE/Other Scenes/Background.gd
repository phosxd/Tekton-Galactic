extends Node2D

@export var texture_layer_mode:CanvasItemMaterial.BlendMode = CanvasItemMaterial.BLEND_MODE_MIX
@export var textures:Array[String]
@export var texture_scales:Array[Vector2]
@export var texture_modulators:Array[Color]
@export var parallax_scroll_scales:Array[Vector2]
@export var parallax_scroll_offsets:Array[Vector2]
@export var parallax_autoscrolls:Array[Vector2]
@export var parallax_repeat_times:Array[int]


func _ready() -> void:
	for i in range(self.textures.size()):
		self.texture_modulators.append(Color.WHITE)
		self.texture_scales.append(Vector2.ONE)
		self.parallax_scroll_scales.append(Vector2.ONE)
		self.parallax_scroll_offsets.append(Vector2.ZERO)
		self.parallax_autoscrolls.append(Vector2.ZERO)
		self.parallax_repeat_times.append(0)

		var texture:Texture2D = SandboxManager.get_texture(self.textures[i])

		var new_parallax := Parallax2D.new()
		new_parallax.scroll_scale = self.parallax_scroll_scales[i]
		new_parallax.scroll_offset = self.parallax_scroll_offsets[i]
		new_parallax.autoscroll = self.parallax_autoscrolls[i]
		new_parallax.repeat_size = texture.get_size()*self.texture_scales[i]
		new_parallax.repeat_times = self.parallax_repeat_times[i]

		var layering_material := CanvasItemMaterial.new()
		layering_material.blend_mode = texture_layer_mode

		var new_sprite := Sprite2D.new()
		new_sprite.texture = texture
		new_sprite.scale = self.texture_scales[i]
		new_sprite.position = (texture.get_size()/2)
		new_sprite.self_modulate = self.texture_modulators[i]
		new_sprite.material = layering_material
		new_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		new_parallax.add_child(new_sprite)
		self.add_child(new_parallax)
