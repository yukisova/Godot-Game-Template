shader_type canvas_item;

// 距离场圆形
float sdCircle(vec2 p, float r){
    return length(p) - r;
}

void fragment(){
	vec2 uv = UV;
	uv -= 0.5;
	
	float pct = sdCircle(uv, 0.5);
	float is_draw = 1.-smoothstep(-0.01,0.01,pct);
	vec3 color = vec3(is_draw);
	float alpha = 1.0-step(is_draw,0.9);
	
	
	
	COLOR = vec4(color,alpha);
}