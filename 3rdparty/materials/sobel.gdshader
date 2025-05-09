shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float highlight_power : hint_range(0.0, 10.0) = 3.0;
uniform float highlight_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float rim_power : hint_range(1.0, 10.0) = 3.0;
uniform vec3 color : source_color;

void fragment() {
    vec4 albedo_tex = vec4(color, 1.0);

    float rim = 1.0 - dot(NORMAL, VIEW);
    rim = pow(rim, rim_power);

    vec4 final_color = albedo_tex;
    final_color.rgb = mix(final_color.rgb, highlight_color.rgb, rim * highlight_intensity);

    ALBEDO = final_color.rgb;
	ALPHA = rim * highlight_intensity * highlight_power;
    EMISSION = highlight_color.rgb * rim * highlight_intensity * highlight_power;
}