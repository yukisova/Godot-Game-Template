shader_type canvas_item;

uniform float lod: hint_range(0.0, 1.0);


void fragment() {
	vec2 uv = UV;
	vec2 halfpixel = TEXTURE_PIXEL_SIZE / 2.0;
	float offset = lod * 3.0;
	vec4 sum = texture(TEXTURE, uv + vec2(-halfpixel.x * 2.0, 0.0) * offset);
	sum += texture(TEXTURE, uv + vec2(-halfpixel.x, halfpixel.y) * offset) * 2.0;
	sum += texture(TEXTURE, uv + vec2(0.0, halfpixel.y * 2.0) * offset);
	sum += texture(TEXTURE, uv + vec2(halfpixel.x, halfpixel.y) * offset) * 2.0;
	sum += texture(TEXTURE, uv + vec2(halfpixel.x * 2.0, 0.0) * offset);
	sum += texture(TEXTURE, uv + vec2(halfpixel.x, -halfpixel.y) * offset) * 2.0;
	sum += texture(TEXTURE, uv + vec2(0.0, -halfpixel.y * 2.0) * offset);
	sum += texture(TEXTURE, uv + vec2(-halfpixel.x, -halfpixel.y) * offset) * 2.0;

	COLOR = sum / 12.0;
	if (COLOR.a > 0.){
		COLOR.a = COLOR.a * (1. - offset / 3.);
	}
}
