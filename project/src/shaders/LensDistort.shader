// Derived from https://www.shadertoy.com/view/4s2GRR#

shader_type canvas_item;
const float PI = 3.1415926535;
uniform vec2 resolution = vec2(640,480);
uniform float factor = 0;

void fragment()
{
	vec2 p = SCREEN_UV;
	float prop = resolution.x / resolution.y;
	vec2 m = vec2(0.5, 0.5);
	vec2 d = p - m;
	float r = sqrt(dot(d, d));
	
	float power = ( 2.0 * PI / (2.0 * sqrt(dot(m, m))) ) * (factor - 0.5);
	float bind = m.y;
	
	if (power > 0.0) bind = sqrt(dot(m, m));
	else if (prop < 1.0) bind = m.x;

	vec2 uv = SCREEN_UV;
	if (power > 0.0)
		uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
	else if (power < 0.0)
		uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
	
	vec3 col = texture(SCREEN_TEXTURE, vec2(uv.x, uv.y)).xyz;
	COLOR = vec4(col, 1.0);
}
