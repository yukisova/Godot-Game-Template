shader_type canvas_item;

// 以颜色面板设置
uniform vec4 blink_color: source_color;

uniform float blink_intensity = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color = mix(color, blink_color, blink_intensity);
	
	COLOR = color;
}