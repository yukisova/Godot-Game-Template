shader_type canvas_item;

uniform sampler2D perlin_noise: repeat_enable;
uniform sampler2D cell_noise: repeat_enable;

#define pow2(x) (x * x)
#define iResolution 1.0/SCREEN_PIXEL_SIZE

const int samples = 35;
const float sigma = float(samples) * 0.25;

float gaussian(vec2 i) {
	return 1.0 / (2.0 * PI * pow2(sigma)) * exp(-((pow2(i.x) + pow2(i.y)) / (2.0 * pow2(sigma))));
}

vec3 blur(sampler2D sp, vec2 uv, vec2 scale) {
	vec3 col = vec3(0.0);
	float accum = 0.0;
	float weight;
	vec2 offset;
	for (int x = -samples / 2; x < samples / 2; ++x) {
		for (int y = -samples / 2; y < samples / 2; ++y) {
			offset = vec2(float(x), float(y));
			weight = gaussian(offset);
			col += texture(sp, uv + scale * offset).rgb * weight;
			accum += weight;
		}
	}
	return col / accum;
}

void fragment() {
	vec2 uv1 = vec2(UV.x + TIME * .02, UV.y + TIME * .005);
	vec2 uv2 = vec2(UV.x + TIME * .03, UV.y + TIME * .005);
	float noise1 = blur(perlin_noise, uv1, SCREEN_PIXEL_SIZE).r;
	float noise2 = blur(cell_noise, uv2, SCREEN_PIXEL_SIZE).r;
	
	float noise = smoothstep(noise1 * noise2 * 1.0, .0, .15);
	
	COLOR = vec4(1,1,1, noise);
}
