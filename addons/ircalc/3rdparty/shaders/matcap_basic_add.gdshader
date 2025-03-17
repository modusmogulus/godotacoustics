// Special thanks to Ben Cloward for the amazing Material tutorial which improved this shader 20x!!
// Video here: https://www.youtube.com/watch?v=osgMB0mf23w
// Thanks to FireRabbit for the base which I pulled apart!

shader_type spatial;
render_mode blend_mix, unshaded, fog_disabled;

uniform sampler2D mask : source_color, hint_default_white;
uniform sampler2D matcap : source_color, hint_default_transparent;
uniform float metalness : hint_range(0.0,1.0) = 1.0;
uniform vec4 color : source_color = vec4(1.0);
//uniform sampler2D screentex : hint_screen_texture;

void fragment() {
	vec2 matcap_uv = (NORMAL.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	vec3 tempcol;
	ALBEDO = color.rgb;
	tempcol = color.rgb;
	ALBEDO *= mix(vec3(1.0), texture(matcap, matcap_uv).rgb, metalness);
	//ALBEDO = texture(screentex, SCREEN_UV).rgb;
	ALPHA = texture(matcap, matcap_uv).a*color.a*texture(mask, UV).a;
}