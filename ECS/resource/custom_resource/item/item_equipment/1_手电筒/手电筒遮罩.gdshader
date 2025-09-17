shader_type canvas_item;

// 遮罩纹理
uniform sampler2D mask_texture : filter_linear_mipmap;
// 遮罩位置
uniform vec2 mask_position = vec2(0.0, 0.0);
// 遮罩对应的Sprite2D的偏移
uniform vec2 mask_offset = vec2(0.0, 0.0);
// 遮罩缩放
uniform vec2 mask_scale = vec2(1.0, 1.0);
// 遮罩旋转（弧度）
uniform float mask_rotation = 0.0;
// 遮罩强度
uniform float mask_strength : hint_range(0.0, 1.0) = 1.0;
// 是否反转遮罩
uniform bool invert_mask = false;

varying vec2 world_position;

vec2 pos_rotate(vec2 pos, float rotation) {
	float cos_rot = cos(-rotation);
	float sin_rot = sin(-rotation);
	return vec2(
		pos.x * cos_rot - pos.y * sin_rot,
		pos.x * sin_rot + pos.y * cos_rot
	);
}

vec2 pos_to_uv(vec2 pos, vec2 scale) {
	return (pos / scale) + vec2(0.5);
}

void vertex() {
	// 计算世界坐标
	// MODEL_MATRIX 是节点相对于世界坐标系的变换矩阵
	// VERTEX 是顶点的本地坐标
	// MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0) 将顶点从本地坐标系转换到世界坐标系
	// 结果是一个4D向量，其中xy是顶点在世界坐标系中的位置，zw是齐次坐标
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// 获取原始颜色
	vec4 tex_color = texture(TEXTURE, UV);
	
	// 计算相对于遮罩的坐标
	// world_position 是顶点在世界坐标系中的位置, 由vertex()函数计算，说白了就是被遮罩的精灵在世界坐标系中的位置
	// mask_position 是遮罩在世界坐标系中的位置，由外部传入
	// relative_pos 是顶点相对于遮罩的位置
	vec2 relative_pos = world_position - mask_position;

	// 先应用旋转（将世界坐标转换到遮罩的本地坐标系）
	vec2 rotated_pos = pos_rotate(relative_pos, mask_rotation);
	
	// 再应用偏移（Sprite2D的offset是在本地坐标系中的）
	// 注意：offset需要取反，因为offset是sprite相对于锚点的偏移，而我们需要的是相反方向
	rotated_pos = rotated_pos - mask_offset;
	
	// 应用缩放和转换到UV坐标 (0-1范围)
	vec2 mask_uv = pos_to_uv(rotated_pos, mask_scale);
	
	// 检查UV坐标是否在有效范围内
	if (mask_uv.x < 0.0 || mask_uv.x > 1.0 || mask_uv.y < 0.0 || mask_uv.y > 1.0) {
		// 超出遮罩范围，根据反转设置决定显示
		if (invert_mask) {
			COLOR = tex_color;
		} else {
			COLOR = vec4(tex_color.rgb, 0.0);
		}
	}
	
	// 根据纹理坐标采样遮罩纹理
	float mask_value = texture(mask_texture, mask_uv).a;
	
	// 根据是否反转遮罩来计算最终的alpha值
	if (invert_mask) {
		mask_value = 1.0 - mask_value;
	}
	
	// 应用遮罩强度
	mask_value = mix(1.0, mask_value, mask_strength);
	
	// 设置最终颜色
	COLOR = tex_color;
	COLOR.a *= mask_value;
}
