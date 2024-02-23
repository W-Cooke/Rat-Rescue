shader_type canvas_item;

uniform vec2 direction = vec2(-1.0, 0.0);
uniform float speed = 0.3;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV + (direction * TIME * speed));
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
