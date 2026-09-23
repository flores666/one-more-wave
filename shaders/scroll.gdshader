// Slides a horizontally tiling texture sideways forever, for the drifting sky layers.
shader_type canvas_item;

// Texture pixels per second. TIME wraps every hour (the default rollover), so the drift
// only loops without a jump when 3600 * speed is a whole number of texture widths.
uniform float speed = 4.0;

void fragment() {
	COLOR = texture(TEXTURE, UV + vec2(TIME * speed * TEXTURE_PIXEL_SIZE.x, 0.0));
}
