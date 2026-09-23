shader_type canvas_item;

// 0 = normal, 1 = fully white.
uniform float flash : hint_range(0.0, 1.0) = 0.0;
// Horizontal sway amplitude in pixels; the base (UV.y = 1) stays planted.
uniform float shake : hint_range(0.0, 4.0) = 0.0;
uniform float shake_speed = 70.0;

void vertex() {
	VERTEX.x += sin(TIME * shake_speed) * shake * (1.0 - UV.y);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(mix(c.rgb, vec3(1.0), flash), c.a);
}
