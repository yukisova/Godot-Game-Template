shader_type canvas_item;

// 以颜色面板设置
uniform vec4 blink_color: source_color;

uniform float blink_intensity = 0.0;

void fragment() {
	vec4 origin_color = texture(TEXTURE, UV);
	vec4 white_color = vec4(blink_color.rgb, origin_color.a);
	
	vec4 final_color = mix(origin_color, white_color, blink_intensity);
	
	COLOR = final_color;
}