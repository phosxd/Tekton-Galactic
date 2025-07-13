shader_type canvas_item;

void fragment() {
	COLOR.b = COLOR.b+0.25;
	if (COLOR.r > 1.0) {COLOR.r = 1.0;}
}