shader_type spatial;
render_mode unshaded;

uniform sampler2D matcap: hint_default_white;
uniform sampler2D normal_map: hint_normal;
uniform vec3 scale;
uniform vec3 offset;

varying vec3 t_pos1;
varying vec3 pn1;

vec4 triplanar_texture(sampler2D samp1,vec3 pn,vec3 t_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(samp1,t_pos.xy) * pn.z;
	samp+= texture(samp1,t_pos.xz) * pn.y;
	samp+= texture(samp1,t_pos.zy * vec2(-1.0,1.0)) * pn.x;
	return samp;
}

void vertex() {
	pn1=pow(abs(NORMAL),vec3(1.0));
	pn1/=dot(pn1,vec3(1.0));
	t_pos1 = VERTEX * scale + offset;
	t_pos1 *= vec3(1.0,-1.0, 1.0);
}

void fragment() {
	vec4 normal = (triplanar_texture(normal_map, pn1, t_pos1) * 2.0 - 1.0);
	vec3 normalV = mat3(TANGENT, BINORMAL, NORMAL) * normal.xyz;
	vec2 uv = normalV.xy * vec2(0.48, -0.48) + 0.5;
	ALBEDO = texture(matcap, uv).rgb;
}
