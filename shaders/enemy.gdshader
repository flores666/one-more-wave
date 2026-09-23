// Recolours the black silhouette character art: dark pixels take the body colour, light ones (the eyes)
// the eye colour. Flash whitens the whole sprite for hit feedback.
shader_type canvas_item;

uniform vec4 body : source_color = vec4(0.7, 0.2, 0.2, 1.0);
uniform vec4 eyes : source_color = vec4(1.0, 0.85, 0.3, 1.0);
uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 col = mix(body.rgb, eyes.rgb, step(0.5, c.r));
	COLOR = vec4(mix(col, vec3(1.0), flash), c.a);
}
