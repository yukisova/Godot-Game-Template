shader_type canvas_item;

// 雾效果参数
uniform sampler2D noise_texture : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float fog_density : hint_range(0.0, 1.0) = 0.6;
uniform float fog_speed : hint_range(0.01, 5.0) = 0.8;
uniform vec4 fog_color : source_color = vec4(0.85, 0.87, 0.92, 0.8);
uniform float fog_scale : hint_range(0.1, 5.0) = 1.2;
uniform vec2 fog_direction = vec2(0.5, 0.1);

// 噪声参数
uniform float noise_contrast : hint_range(0.1, 2.0) = 1.5;
uniform float edge_softness : hint_range(0.1, 1.0) = 0.4;

void fragment() {
    // 获取当前像素的UV坐标
    vec2 uv = UV;
    
    // 创建移动的噪声坐标
    vec2 noise_uv1 = uv * fog_scale + fog_direction * TIME * fog_speed;
    vec2 noise_uv2 = uv * fog_scale * 1.7 + fog_direction * TIME * fog_speed * 0.6;
    vec2 noise_uv3 = uv * fog_scale * 0.3 + fog_direction * TIME * fog_speed * 0.3;
    
    // 获取多层噪声
    float noise1 = texture(noise_texture, noise_uv1).r;
    float noise2 = texture(noise_texture, noise_uv2).r;
    float noise3 = texture(noise_texture, noise_uv3).r;
    
    // 组合噪声
    float combined_noise = (noise1 * 0.5 + noise2 * 0.3 + noise3 * 0.2);
    
    // 增强对比度
    combined_noise = pow(combined_noise, noise_contrast);
    
    // 创建雾的遮罩 - 使用smoothstep让边缘更柔和
    float fog_mask = smoothstep(0.3, 0.3 + edge_softness, combined_noise);
    
    // 添加径向渐变效果（中心较少雾，边缘较多雾）
    vec2 center_dist = abs(uv - vec2(0.5));
    float radial_factor = 1.0 + (center_dist.x + center_dist.y) * 0.8;
    fog_mask *= radial_factor;
    
    // 应用整体密度
    fog_mask *= fog_density;
    fog_mask = clamp(fog_mask, 0.0, 1.0);
    
    // 输出雾的颜色，使用计算的遮罩作为alpha
    COLOR = vec4(fog_color.rgb, fog_mask * fog_color.a);
}
