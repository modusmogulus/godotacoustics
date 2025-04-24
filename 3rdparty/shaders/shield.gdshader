shader_type spatial;
render_mode unshaded, cull_disabled;

/*
RING SHADER
*/


uniform vec3 ring_color: source_color = vec3(1.0);
uniform float ring_frequency = 50.0;
/** Portion of the visible rings. Negative values give wider rings, positive values give narrower rings*/
uniform float ring_portion: hint_range(-0.9, 0.9, 0.1) = 0.0;
/** Negative values move the rings outwards, positive value move the rings inwards */
uniform float move_speed = -10.0;
uniform bool smooth_edge = false;

uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float highlight_power : hint_range(0.0, 10.0) = 3.0;
uniform float highlight_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float rim_power : hint_range(1.0, 10.0) = 3.0;
uniform vec3 color : source_color;

void fragment() {
	
    float rim = 1.0 - dot(NORMAL, VIEW);
    rim = pow(rim, rim_power);

    vec4 albedo_tex = vec4(color, 1.0);
    vec4 final_color = albedo_tex;
    final_color.rgb = mix(final_color.rgb, highlight_color.rgb, rim * highlight_intensity);

    vec3 albs = final_color.rgb;
	float alps = rim * highlight_intensity * highlight_power;
    vec3 emis = highlight_color.rgb * rim * highlight_intensity * highlight_power;

	float dist = distance(UV, vec2(0.5,0.5));
	float rings = sin(dist * ring_frequency + (TIME * move_speed));
	rings = step(ring_portion, rings);
	float blend_alpha = smoothstep(0.5, 0.4, dist);
	if (dist > 0.5 || rings < 1.0){
		ALPHA = 0.0;
	}
	else if (rings > 0.0){
		ALBEDO = ring_color*albs;
		ALPHA = smooth_edge ? blend_alpha : alps;
		
	}
}
