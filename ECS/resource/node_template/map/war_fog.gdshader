shader_type canvas_item;

uniform vec4 fog_color: source_color;
uniform sampler2D current_texture;

void fragment(){
	COLOR.rgb = fog_color.rgb;
	COLOR.a = (texture(TEXTURE, UV).r + texture(current_texture, UV).r)/ 2.;
}