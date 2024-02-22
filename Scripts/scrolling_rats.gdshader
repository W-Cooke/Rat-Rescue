// trying my hand at writing a shader!
shader_type canvas_item;

uniform float speed;

// In theory this should scroll diagonally based off the speed variable
void fragment () {
	COLOR = texture(TEXTURE, vec2(UV.x + TIME * speed, UV.y + TIME * speed));
}