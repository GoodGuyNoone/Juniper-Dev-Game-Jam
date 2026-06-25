shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

group_uniforms Textures;
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform bool use_albedo_texture = true;
uniform int color_source : hint_enum("Texture", "Gradient") = 0;
uniform int alpha_source : hint_enum("Texture Alpha", "Texture Brightness", "Inverted Texture Brightness") = 0;

group_uniforms Color;
uniform vec4 bottom_color : source_color = vec4(0.08, 0.32, 0.09, 1.0);
uniform vec4 top_color : source_color = vec4(0.42, 0.82, 0.23, 1.0);
uniform float color_mix_strength : hint_range(0.0, 1.0, 0.01) = 0.65;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.01) = 0.45;

group_uniforms Wind;
uniform vec2 wind_direction = vec2(1.0, 0.35);
uniform float wind_speed : hint_range(0.0, 8.0, 0.01) = 1.6;
uniform float wind_strength : hint_range(0.0, 2.0, 0.01) = 0.18;
uniform float noise_scale : hint_range(0.01, 10.0, 0.01) = 1.2;
uniform float wave_frequency : hint_range(0.1, 20.0, 0.01) = 5.0;
uniform bool invert_height_mask = false;

varying float height_mask;


void vertex() {
	height_mask = invert_height_mask ? 1.0 - UV.y : UV.y;
	height_mask = smoothstep(0.0, 1.0, height_mask);

	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 wind_dir = normalize(wind_direction);
	vec2 noise_uv = world_position.xz * noise_scale + wind_dir * TIME * wind_speed;
	float noise_value = texture(noise_texture, noise_uv).r * 2.0 - 1.0;
	float wave_value = sin(TIME * wind_speed + world_position.x * wave_frequency + noise_value);
	float bend = wave_value * wind_strength * height_mask;

	VERTEX.xz += wind_dir * bend;
	VERTEX.y += abs(bend) * 0.08 * height_mask;
}


void fragment() {
	vec4 tex = use_albedo_texture ? texture(albedo_texture, UV) : vec4(1.0);
	vec3 gradient_color = mix(bottom_color.rgb, top_color.rgb, height_mask);
	vec3 final_color = gradient_color;
	if (color_source == 0) {
		final_color = mix(tex.rgb, tex.rgb * gradient_color, color_mix_strength);
	}
	float texture_brightness = max(max(tex.r, tex.g), tex.b);
	float alpha = tex.a;

	if (alpha_source == 1) {
		alpha = texture_brightness;
	} else if (alpha_source == 2) {
		alpha = 1.0 - texture_brightness;
	}

	ALBEDO = final_color;
	ROUGHNESS = 0.85;
	ALPHA = alpha;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}
