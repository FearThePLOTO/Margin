shader_type canvas_item;
// Pause screen: the frozen game turns cold blue and dims, so the menu pops.
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float amount : hint_range(0.0, 1.0) = 1.0;
uniform vec3 shadow_col : source_color = vec3(0.04, 0.06, 0.18);
uniform vec3 light_col : source_color = vec3(0.45, 0.62, 1.0);

void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	vec3 blue = mix(shadow_col, light_col, l * 0.8);
	COLOR = vec4(mix(c, blue, amount * 0.9), 1.0);
}
