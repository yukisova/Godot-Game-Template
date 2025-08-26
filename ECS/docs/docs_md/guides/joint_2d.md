# Joint2D 节点使用指南

本指南介绍 Godot 中 Joint2D 的三个主要继承节点：PinJoint2D、DampedSpringJoint2D 和 GrooveJoint2D，以及它们的使用场景和参数配置。

## PinJoint2D - 销关节

PinJoint2D 将两个刚体通过一个固定点连接，类似于用钉子将两个物体钉在一起。

### 测试场景
- **场景路径**: `scene/launcher/test/test_pin_joint_2d.tscn`
- **脚本**: `scene/launcher/test/test_pin_joint_2d.gd`

### 主要参数
- **softness**: 关节软度 (0.0-1.0)，控制关节的弹性
- **bias**: 关节偏差 (0.0-1.0)，控制关节的稳定性
- **disable_collision**: 是否禁用两个刚体之间的碰撞

**注意**: PinJoint2D 在 Godot 4.x 中不支持 max_force 属性

### 使用场景
- 链条连接
- 摆锤系统
- 机械臂关节
- 绳索连接

### 快捷键
- **1**: 重置参数
- **2**: 软关节设置
- **3**: 硬关节设置
- **4**: 切换碰撞
- **R**: 重置位置

### 代码示例
```gdscript
# 创建 PinJoint2D
var pin_joint = PinJoint2D.new()
pin_joint.softness = 0.0  # 硬关节
pin_joint.bias = 0.2      # 偏差
pin_joint.disable_collision = false  # 启用碰撞

# 连接两个刚体
pin_joint.node_a = body_a.get_path()
pin_joint.node_b = body_b.get_path()
```

## DampedSpringJoint2D - 阻尼弹簧关节

DampedSpringJoint2D 在两个刚体之间创建一个弹簧连接，具有可调节的阻尼效果。

### 测试场景
- **场景路径**: `scene/launcher/test/test_damped_spring_joint_2d.tscn`
- **脚本**: `scene/launcher/test/test_damped_spring_joint_2d.gd`

### 主要参数
- **rest_length**: 弹簧自然长度，弹簧试图保持的距离
- **stiffness**: 弹簧刚度，控制弹簧的强度
- **damping**: 阻尼系数，控制弹簧振动的衰减
- **disable_collision**: 是否禁用两个刚体之间的碰撞

### 使用场景
- 弹簧系统
- 悬挂系统
- 弹性连接
- 物理模拟

### 快捷键
- **1**: 重置参数
- **2**: 软弹簧设置
- **3**: 硬弹簧设置
- **4**: 无阻尼弹簧
- **5**: 高阻尼弹簧
- **6**: 切换碰撞
- **R**: 重置位置

### 代码示例
```gdscript
# 创建 DampedSpringJoint2D
var spring_joint = DampedSpringJoint2D.new()
spring_joint.rest_length = 100.0  # 自然长度
spring_joint.stiffness = 50.0     # 刚度
spring_joint.damping = 1.0        # 阻尼
spring_joint.disable_collision = false  # 启用碰撞

# 连接两个刚体
spring_joint.node_a = body_a.get_path()
spring_joint.node_b = body_b.get_path()
```

## GrooveJoint2D - 槽关节

GrooveJoint2D 允许一个刚体沿着另一个刚体上定义的槽移动，类似于轨道系统。

### 测试场景
- **场景路径**: `scene/launcher/test/test_groove_joint_2d.tscn`
- **脚本**: `scene/launcher/test/test_groove_joint_2d.gd`

### 主要参数
- **groove_a**: 槽的起点位置
- **groove_b**: 槽的终点位置
- **anchor**: 锚点位置，连接点相对于第二个刚体的位置
- **softness**: 关节软度
- **bias**: 关节偏差
- **max_force**: 最大力
- **disable_collision**: 是否禁用碰撞

### 使用场景
- 轨道系统
- 滑块机构
- 机械导轨
- 约束运动

### 快捷键
- **1**: 重置参数
- **2**: 水平槽
- **3**: 垂直槽
- **4**: 对角线槽
- **5**: 弧形槽
- **6**: 切换碰撞
- **R**: 重置位置

### 代码示例
```gdscript
# 创建 GrooveJoint2D
var groove_joint = GrooveJoint2D.new()
groove_joint.groove_a = Vector2(-50, 0)  # 槽起点
groove_joint.groove_b = Vector2(50, 0)   # 槽终点
groove_joint.anchor = Vector2(0, 0)      # 锚点
groove_joint.softness = 0.0              # 软度
groove_joint.bias = 0.2                  # 偏差
groove_joint.max_force = 1000.0          # 最大力
groove_joint.disable_collision = false   # 启用碰撞

# 连接两个刚体
groove_joint.node_a = body_a.get_path()
groove_joint.node_b = body_b.get_path()
```

## 参数调优指南

### PinJoint2D 调优
- **软度 (softness)**: 0.0 = 硬连接，1.0 = 完全弹性
- **偏差 (bias)**: 0.0 = 无偏差，1.0 = 最大偏差
- **碰撞控制**: 禁用不必要的碰撞可以提高性能

### DampedSpringJoint2D 调优
- **自然长度 (rest_length)**: 设置弹簧的平衡长度
- **刚度 (stiffness)**: 高值 = 硬弹簧，低值 = 软弹簧
- **阻尼 (damping)**: 0.0 = 无阻尼（持续振动），高值 = 快速衰减

### GrooveJoint2D 调优
- **槽位置**: 定义运动路径
- **锚点**: 控制连接点的位置
- **软度和偏差**: 影响关节的稳定性和响应性

## 性能考虑

1. **关节数量**: 过多的关节会影响性能
2. **参数设置**: 不合理的参数可能导致不稳定
3. **碰撞检测**: 禁用不必要的碰撞可以提高性能
4. **物理步长**: 调整物理步长以平衡精度和性能

## 最佳实践

1. **合理设计**: 根据实际需求选择合适的关节类型
2. **参数调优**: 逐步调整参数，观察效果
3. **性能监控**: 监控物理性能，避免过度复杂
4. **测试验证**: 在不同条件下测试关节行为
5. **文档记录**: 记录参数设置和使用场景

## 常见问题

### PinJoint2D
- **Q**: 关节太松或太紧？
- **A**: 调整 softness 和 bias 参数

### DampedSpringJoint2D
- **Q**: 弹簧振动太剧烈？
- **A**: 增加 damping 值或降低 stiffness

### GrooveJoint2D
- **Q**: 物体不按预期路径移动？
- **A**: 检查 groove_a 和 groove_b 的设置，确保路径正确

## 高级应用

### 复合关节系统
可以组合多个关节创建复杂的机械系统：
```gdscript
# 创建链条系统
for i in range(chain_length):
    var pin_joint = PinJoint2D.new()
    pin_joint.node_a = chain_parts[i].get_path()
    pin_joint.node_b = chain_parts[i + 1].get_path()
    add_child(pin_joint)
```

### 动态关节创建
在运行时创建和销毁关节：
```gdscript
# 动态创建弹簧连接
func create_spring_connection(body1: RigidBody2D, body2: RigidBody2D):
    var spring = DampedSpringJoint2D.new()
    spring.node_a = body1.get_path()
    spring.node_b = body2.get_path()
    spring.rest_length = body1.global_position.distance_to(body2.global_position)
    add_child(spring)
```
