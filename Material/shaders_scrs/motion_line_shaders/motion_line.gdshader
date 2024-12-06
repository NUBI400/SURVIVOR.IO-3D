shader_type canvas_item;

uniform float line_alpha = 0.0;
uniform float scale_line = 128;
uniform float speedScale = 16.0;
uniform float clipPosition = 0.2;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	COLOR.a = 0.0;
	
	vec2 pos = UV - vec2(0.5);
	float theta = round(scale_line * atan(pos.y, pos.x));
	float dist = sqrt(pow(pos.x, 2) + pow(pos.y, 2));
	
	float distValue = round(dist * 4.0 + TIME * -speedScale + 8.0 * random(vec2(theta)));
	if (dist > clipPosition + random(vec2(theta)) * 0.3 && random(vec2(theta, distValue)) < 0.02) {
		COLOR.a = line_alpha;
	}
}