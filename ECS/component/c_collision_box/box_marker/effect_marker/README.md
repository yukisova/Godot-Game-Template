# 受击特效系统

这个文件夹包含了一个基于 GPU_Particles2D 的受击特效系统，可以根据外部传入的 Vector2 方向参数来显示受击特效。

## 文件结构

- `hit_effect.tscn` - 受击特效场景文件
- `hit_effect.gd` - 受击特效脚本，包含 HitEffect 类
- `hit_effect_example.gd` - 使用示例脚本
- `hit_effect_test_scene.tscn` - 测试场景文件
- `hit_effect_test_scene.gd` - 测试场景脚本
- `hit_effect.gd.uid` - Godot 资源 UID 文件
- `README.md` - 说明文档

## 快速测试

### 🎮 运行测试场景
在 Godot 编辑器中打开 `hit_effect_test_scene.tscn` 文件并运行场景，即可立即测试受击特效！

**测试操作说明：**
- **鼠标左键点击**: 在点击位置播放受击特效
- **空格键**: 在中心播放向上的特效
- **按1键**: 红色受击特效
- **按2键**: 黄色爆炸特效
- **按3键**: 蓝色冰霜特效
- **按R键**: 随机方向和颜色的特效
- **按C键**: 清理所有特效
- **按ESC键**: 退出测试场景

## 如何使用

### 1. 基本使用

```gdscript
# 在你的场景中实例化受击特效
var hit_effect_scene = preload("res://component/c_marker/effect_marker/hit_effect.tscn")
var hit_effect_instance = hit_effect_scene.instantiate()
add_child(hit_effect_instance)

# 播放受击特效，传入受击方向
var hit_direction = Vector2(1, 0)  # 向右的方向
hit_effect_instance.play_hit_effect(hit_direction)
```

### 2. 高级配置

```gdscript
# 设置粒子数量和持续时间
hit_effect_instance.set_effect_parameters(100, 0.8)  # 100个粒子，持续0.8秒

# 设置粒子颜色
hit_effect_instance.set_particle_color(Color.RED, Color.TRANSPARENT)  # 红色渐变到透明
```

### 3. 实际使用场景

```gdscript
# 角色受到攻击时
func on_character_hit(attack_position: Vector2, character_position: Vector2):
    var hit_direction = (character_position - attack_position).normalized()
    hit_effect_instance.play_hit_effect(hit_direction)

# 敌人死亡时
func on_enemy_death():
    hit_effect_instance.set_particle_color(Color.YELLOW, Color.TRANSPARENT)
    hit_effect_instance.play_hit_effect(Vector2.UP)
```

## 主要功能

### play_hit_effect(direction: Vector2)
播放受击特效的主要函数
- `direction`: 受击方向，如果为零向量则使用默认方向(Vector2.UP)
- 粒子会向指定方向散开，营造受击效果

### set_effect_parameters(particle_amount: int, duration: float)
设置特效参数
- `particle_amount`: 粒子数量（默认50）
- `duration`: 特效持续时间（默认0.5秒）

### set_particle_color(start_color: Color, end_color: Color)
设置粒子颜色渐变
- `start_color`: 起始颜色
- `end_color`: 结束颜色（默认透明）

## 技术特点

1. **基于 GPU_Particles2D**: 高性能的粒子系统
2. **方向感知**: 根据传入的方向参数调整粒子发射方向
3. **高度可配置**: 可以调整粒子数量、持续时间、颜色等
4. **自动管理**: 特效播放后自动停止，无需手动管理生命周期
5. **易于集成**: 简单的 API 设计，易于在现有项目中集成

## 默认参数

- 粒子数量: 50
- 持续时间: 0.5秒
- 默认方向: Vector2.UP (向上)
- 初始速度: 50-150 像素/秒
- 重力: Vector3(0, 98, 0)
- 扩散角度: 45度
- 颜色: 白色渐变到透明

## 注意事项

- 在使用前确保场景已经添加到场景树中
- 可以通过修改脚本中的默认参数来调整特效表现
- 如果需要不同类型的特效，可以复制这个模板并修改参数
