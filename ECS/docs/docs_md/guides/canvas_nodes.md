# Canvas 节点使用指南

本指南介绍 Godot 中三个重要的 Canvas 节点：CanvasGroup、CanvasModulate 和 Parallax2D，以及它们的使用场景和最佳实践。

## CanvasGroup - 画布组

CanvasGroup 允许你对一组节点进行统一的透明度、可见性和混合模式控制。

### 测试场景
- **场景路径**: `scene/launcher/test/test_canvas_group.tscn`
- **脚本**: `scene/launcher/test/test_canvas_group.gd`

### 主要功能
- **统一透明度控制**: 通过 `modulate.a` 控制整个组的透明度
- **可见性控制**: 通过 `visible` 属性控制整个组的显示/隐藏
- **Modulate 控制**: 通过 `modulate` 属性进行颜色和透明度调整

**注意**: Godot 4.x 中 CanvasGroup 功能相对简化，主要支持透明度、可见性和 modulate 控制

### 使用场景
- UI 元素的淡入淡出效果
- 游戏对象的整体隐藏/显示
- 特殊视觉效果（如发光、阴影等）
- 性能优化（批量控制多个节点）

### 快捷键
- **1**: 淡入效果
- **2**: 淡出效果
- **3**: 闪烁效果
- **4**: 切换可见性

### 代码示例
```gdscript
# 创建 CanvasGroup
var canvas_group = CanvasGroup.new()
canvas_group.modulate.a = 0.5  # 设置透明度
canvas_group.visible = true    # 设置可见性
canvas_group.modulate = Color(1, 1, 1, 0.5)  # 设置整体颜色和透明度

# 添加子节点
canvas_group.add_child(sprite1)
canvas_group.add_child(sprite2)
```

## CanvasModulate - 画布调制

CanvasModulate 对整个画布应用颜色调制，影响所有子节点的颜色。

### 测试场景
- **场景路径**: `scene/launcher/test/test_canvas_modulate.tscn`
- **脚本**: `scene/launcher/test/test_canvas_modulate.gd`

### 主要功能
- **全局颜色调制**: 通过 `color` 属性对整个画布进行颜色调制
- **实时颜色变化**: 支持动画和实时颜色调整
- **视觉效果**: 创建氛围、时间效果、特殊滤镜等

### 使用场景
- 游戏时间效果（白天/夜晚）
- 氛围营造（温暖/寒冷色调）
- 特殊效果（黑白、复古、梦幻等）
- 性能优化（避免逐个修改节点颜色）

### 快捷键
- **1-8**: 预设颜色（红、绿、蓝、黄、紫、青、白、黑）
- **9**: 彩虹循环效果
- **0**: 闪烁效果

### 代码示例
```gdscript
# 创建 CanvasModulate
var canvas_modulate = CanvasModulate.new()
canvas_modulate.color = Color.RED  # 红色调制
canvas_modulate.visible = true     # 启用调制

# 动画颜色变化
var tween = create_tween()
tween.tween_property(canvas_modulate, "color", Color.BLUE, 2.0)
```

## Parallax2D - 视差背景

Parallax2D 创建视差滚动效果，通过 ParallaxBackground 和 ParallaxLayer 实现多层背景的深度感。

### 测试场景
- **场景路径**: `scene/launcher/test/test_parallax_2d.tscn`
- **脚本**: `scene/launcher/test/test_parallax_2d.gd`

### 主要组件
- **ParallaxBackground**: 视差背景容器
- **ParallaxLayer**: 视差层，每个层有不同的移动比例
- **motion_scale**: 移动比例，控制层的移动速度

### 使用场景
- 2D 游戏的背景滚动
- 创建深度感和立体感
- 平台游戏的地面滚动
- 横版射击游戏的背景效果

### 快捷键
- **1**: 水平滚动
- **2**: 垂直滚动
- **3**: 对角线滚动
- **4**: 圆形滚动
- **5**: 停止滚动
- **Space**: 切换自动滚动
- **R**: 重置相机位置
- **方向键**: 手动移动（关闭自动滚动时）

### 代码示例
```gdscript
# 创建视差背景
var parallax_bg = ParallaxBackground.new()

# 创建背景层（移动最慢）
var bg_layer = ParallaxLayer.new()
bg_layer.motion_scale = Vector2(0.1, 0.1)
parallax_bg.add_child(bg_layer)

# 创建中景层（中等移动速度）
var mid_layer = ParallaxLayer.new()
mid_layer.motion_scale = Vector2(0.5, 0.5)
parallax_bg.add_child(mid_layer)

# 创建前景层（移动最快）
var fg_layer = ParallaxLayer.new()
fg_layer.motion_scale = Vector2(1.0, 1.0)
parallax_bg.add_child(fg_layer)
```

## 性能考虑

### CanvasGroup
- 适合批量控制多个节点
- 混合模式可能影响性能
- 建议合理使用透明度动画

### CanvasModulate
- 全局颜色调制，性能影响较小
- 适合创建氛围效果
- 避免频繁的颜色变化

### Parallax2D
- 视差层数量影响性能
- 建议使用适当的 motion_scale 值
- 考虑使用纹理图集减少绘制调用

## 最佳实践

1. **合理使用**: 根据实际需求选择合适的节点
2. **性能优化**: 避免过度使用复杂的混合模式
3. **动画控制**: 使用 Tween 创建平滑的过渡效果
4. **层级管理**: 合理组织视差层的层级关系
5. **资源管理**: 及时清理不需要的节点和资源

## 常见问题

### CanvasGroup
- **Q**: 为什么子节点的透明度没有变化？
- **A**: 确保 CanvasGroup 的 `modulate.a` 值正确设置

### CanvasModulate
- **Q**: 颜色调制没有效果？
- **A**: 检查 CanvasModulate 的 `visible` 属性是否启用

### Parallax2D
- **Q**: 视差效果不明显？
- **A**: 调整 ParallaxLayer 的 `motion_scale` 值，数值差异越大效果越明显
