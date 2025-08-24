# 鼠标固定模式功能文档

## 概述

ViewportManager 提供了自定义鼠标固定模式功能，可以将鼠标光标限制在第一个 camera_viewport 的范围内。这个功能特别适用于需要精确鼠标控制的游戏场景，如射击游戏、策略游戏等。

## 功能特性

### 三种鼠标模式

1. **NORMAL（正常模式）**
   - 鼠标可以自由移动
   - 不受任何限制
   - 默认模式

2. **LOCKED（锁定模式）**
   - 鼠标锁定在第一个视口范围内
   - 鼠标不可见，但可以检测相对移动
   - 适用于需要连续鼠标输入的游戏

3. **CONFINED（限制模式）**
   - 鼠标限制在第一个视口范围内但可以移动
   - 鼠标可见，超出范围时自动拉回
   - 适用于需要精确鼠标控制的游戏

## 使用方法

### 基本API

```gdscript
# 获取视口管理器引用
var viewport_manager = get_node("/root/SCameraController/ViewportManager")

# 设置鼠标模式
viewport_manager.set_mouse_mode(ViewportManager.MouseMode.LOCKED)

# 便捷方法
viewport_manager.enable_mouse_lock()        # 启用锁定模式
viewport_manager.enable_mouse_confinement() # 启用限制模式
viewport_manager.disable_mouse_lock()       # 禁用固定模式
viewport_manager.toggle_mouse_lock()        # 切换固定模式

# 获取当前模式
var current_mode = viewport_manager.get_mouse_mode()
```

### 键盘快捷键

- **F1**: 循环切换鼠标模式（NORMAL → LOCKED → CONFINED → NORMAL）
- **ESC**: 释放鼠标锁定（在LOCKED模式下）

### 获取鼠标位置信息

```gdscript
# 获取第一个视口
var first_viewport = viewport_manager.get_first_viewport()

# 获取第一个视口的矩形范围
var viewport_rect = viewport_manager.get_first_viewport_rect()

# 获取鼠标在第一个视口中的位置
var mouse_pos = viewport_manager.get_mouse_position_in_first_viewport()

# 检查鼠标是否在第一个视口范围内
var is_in_viewport = viewport_manager.is_mouse_in_first_viewport()
```

## 实现细节

### 自动处理

- 当视口大小改变时，自动重新计算限制区域
- 当布局改变时，自动更新鼠标限制逻辑
- 支持动态添加/移除视口时的自动调整

### 性能优化

- 只在需要时进行鼠标位置计算
- 避免无限循环的鼠标位置更新
- 高效的矩形碰撞检测

## 测试

使用提供的测试脚本 `mouse_lock_test.gd` 来验证功能：

```gdscript
# 测试按键
F2: 启用鼠标锁定模式
F3: 启用鼠标限制模式
F4: 禁用鼠标固定模式
F5: 切换鼠标固定模式
F6: 显示当前鼠标模式
F7: 显示第一个视口信息
```

## 注意事项

1. **视口依赖**: 鼠标固定模式需要至少有一个可用的视口
2. **平台兼容性**: 某些平台可能对鼠标锁定有限制
3. **UI交互**: 在鼠标锁定模式下，某些UI交互可能受到影响
4. **调试**: 使用 `print()` 输出来调试鼠标位置和模式切换

## 扩展功能

可以根据需要扩展以下功能：

- 支持多个视口的鼠标限制
- 自定义鼠标限制区域
- 鼠标灵敏度调节
- 鼠标轨迹记录
- 鼠标事件过滤

## 示例代码

```gdscript
# 在游戏开始时启用鼠标锁定
func _ready():
    var viewport_manager = get_node("/root/SCameraController/ViewportManager")
    viewport_manager.enable_mouse_lock()

# 在游戏结束时释放鼠标
func _exit_tree():
    var viewport_manager = get_node("/root/SCameraController/ViewportManager")
    viewport_manager.disable_mouse_lock()

# 处理鼠标输入
func _input(event):
    if event is InputEventMouseMotion:
        var viewport_manager = get_node("/root/SCameraController/ViewportManager")
        var mouse_pos = viewport_manager.get_mouse_position_in_first_viewport()
        # 使用鼠标位置进行游戏逻辑
        handle_mouse_movement(mouse_pos)
```



