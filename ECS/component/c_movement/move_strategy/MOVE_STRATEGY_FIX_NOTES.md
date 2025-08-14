# 移动策略修复说明

## 问题描述

在使用 `TempEntity` 和对象池系统时，`MoveStrategyStraight` 的 `_check_and_init()` 方法会报错：

```
Cannot call method 'create_timer' on a null value.
```

## 问题原因

1. **初始化时机问题**: 当 `TempEntity` 从对象池获取时，移动组件的初始化顺序为：
   - 对象池获取对象
   - 调用组件的 `_initialize()` 方法
   - 组件初始化时调用移动策略的 `_check_and_init()`
   - **此时移动策略节点还未添加到场景树**

2. **null 引用**: `get_tree()` 在节点未添加到场景树时返回 `null`

## 修复方案

### 1. 使用绑定实体的场景树
```gdscript
# 修复前
get_tree().create_timer(2.0).timeout.connect(...)

# 修复后  
if binding_entity and binding_entity.is_inside_tree():
    binding_entity.get_tree().create_timer(2.0).timeout.connect(...)
```

### 2. 延迟设置机制
如果绑定实体也不在场景树中，设置延迟标志：
```gdscript
var _deferred_timer_setup: bool = false

# 在 _check_and_init() 中
else:
    _deferred_timer_setup = true

# 在 _update() 中检查并设置
if _deferred_timer_setup and binding_entity and binding_entity.is_inside_tree():
    binding_entity.get_tree().create_timer(2.0).timeout.connect(...)
    _deferred_timer_setup = false
```

## 修复详情

### 修改的文件
- `component/c_movement/move_strategy/straight_move.gd`

### 新增变量
```gdscript
var _deferred_timer_setup: bool = false
```

### 修改的方法
1. **`_check_and_init()`**: 添加了空值检查和延迟设置逻辑
2. **`_update()`**: 添加了延迟定时器设置检查

## 测试验证

### 使用手枪攻击节点测试
```gdscript
# 基础功能测试
pistol_attack_node.test_pistol_integration()

# 专门的修复验证
pistol_attack_node.test_straight_move_fix()
```

### 预期结果
- ✅ 不再出现 "Cannot call method 'create_timer' on a null value" 错误
- ✅ 子弹能正常生成和飞行
- ✅ 销毁定时器正确设置（2秒后自动销毁）

## 兼容性

- ✅ **向后兼容**: 对现有 `FixedEntity` 无影响
- ✅ **对象池兼容**: 完全支持 `TempEntity` 和对象池系统
- ✅ **场景树兼容**: 无论何时添加到场景树都能正确工作

## 其他移动策略

目前只有 `MoveStrategyStraight` 使用了 `get_tree().create_timer()`，其他策略如 `MoveStrategyVector` 没有此问题。

如果将来添加新的移动策略使用定时器，应该：
1. 检查节点是否在场景树中
2. 优先使用 `binding_entity.get_tree()`
3. 必要时实现延迟设置机制

## 注意事项

1. **不要直接调用 `get_tree()`**: 在策略初始化时节点可能不在场景树中
2. **使用绑定实体的树**: `binding_entity.get_tree()` 更可靠
3. **实现延迟机制**: 确保即使在极端情况下也能正确设置定时器

---

这个修复确保了移动策略在对象池系统中的稳定运行。



