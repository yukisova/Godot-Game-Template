# 网格背包系统 (Grid Inventory System)

## 概述

网格背包系统是一个功能完整的物品管理系统，支持基于网格的物品布局、拖拽操作、旋转功能和自动整理。该系统采用ECS架构设计，提供流畅的用户交互体验。

## 主要功能

### 核心特性
- **网格化布局**: 基于二维网格的物品放置系统
- **拖拽操作**: 支持长按拾取和拖拽放置
- **物品旋转**: 在拖拽过程中可以旋转物品
- **位置预览**: 实时显示物品可放置的位置（绿色表示可用，红色表示不可用）
- **自动整理**: 智能的物品重新排列算法
- **碰撞检测**: 精确的物品占用空间验证

### 交互功能
- **长按拾取**: 长按物品0.5秒后可以拾取
- **拖拽移动**: 拾取后可以拖拽到其他位置
- **旋转物品**: 拖拽时按8键可以旋转物品
- **状态查看**: 按9键可以查看当前背包状态

## 系统架构

### 核心组件

#### GridInventory (网格背包主组件)
- 管理整个背包系统的核心逻辑
- 处理用户输入和状态管理
- 协调各个子组件的交互

#### GridInventorySlot (网格槽位)
- 表示背包中的一个可放置位置
- 管理槽位的状态和关联物品
- 提供视觉反馈和高亮效果

#### DragableItem (可拖拽物品)
- 表示背包中的一个物品实例
- 管理物品的显示和状态
- 支持旋转和尺寸调整

### 数据模型

#### Item (物品基类)
```gdscript
class_name Item
extends Resource

@export var item_name: String           # 物品名称
@export var item_description: String    # 物品描述
@export var item_texture: Texture2D     # 物品纹理
@export var item_tilesize: Vector2i     # 物品网格尺寸
@export var item_weight: float          # 物品重量
```

## 使用方法

### 基本设置

1. **创建网格背包场景**
```gdscript
# 在场景中添加GridInventory节点
var grid_inventory = GridInventory.new()
add_child(grid_inventory)
```

2. **配置背包参数**
```gdscript
# 设置背包容量和布局
grid_inventory.grid_num = 20    # 总槽位数
grid_inventory.col_num = 5      # 列数
```

3. **添加物品**
```gdscript
# 创建物品实例
var item = Item.new()
item.item_name = "测试物品"
item.item_tilesize = Vector2i(2, 1)  # 2x1的物品

# 添加到背包
await grid_inventory.add_item(item)
```

### 高级功能

#### 自动整理
```gdscript
# 自动整理背包中的物品
grid_inventory.auto_organize()
```

#### 清空背包
```gdscript
# 移除所有物品
for item in grid_inventory.items_in_inventory:
    grid_inventory.remove_item(item)
    item.queue_free()
```

#### 检查位置可用性
```gdscript
# 检查指定位置是否可以放置物品
var can_place = grid_inventory.is_area_available(Vector2i(0, 0), Vector2i(2, 1))
```

## API 参考

### GridInventory 类

#### 属性
- `grid_num: int` - 网格槽位总数
- `col_num: int` - 网格列数
- `mouse_control_enable: bool` - 是否启用鼠标控制
- `long_press_duration: float` - 长按拾取持续时间
- `rotation_speed: float` - 物品旋转速度

#### 方法
- `add_item(item: Item) -> bool` - 添加物品到背包
- `remove_item(item: DragableItem)` - 移除物品
- `place_item(item: DragableItem, start_index: Vector2i) -> bool` - 在指定位置放置物品
- `auto_organize()` - 自动整理背包
- `is_area_available(start_index: Vector2i, size: Vector2i) -> bool` - 检查区域是否可用
- `get_slot_under_mouse() -> GridInventorySlot` - 获取鼠标下的槽位
- `get_item_under_mouse() -> DragableItem` - 获取鼠标下的物品

#### 信号
- `focus_item_updated(item: Item)` - 焦点物品更新时发出

### GridInventorySlot 类

#### 属性
- `current_index: Vector2i` - 槽位在网格中的坐标
- `linkage_dragable: DragableItem` - 关联的可拖拽物品

#### 方法
- `is_empty() -> bool` - 检查槽位是否为空
- `is_occupied() -> bool` - 检查槽位是否被占用
- `set_highlight(color: Color, alpha: float)` - 设置高亮状态
- `clear_highlight()` - 清除高亮状态

### DragableItem 类

#### 属性
- `binding_item: Item` - 绑定的物品数据
- `item_size: Vector2i` - 物品在网格中的尺寸
- `current_slot: GridInventorySlot` - 当前所在的槽位
- `origin_slot: GridInventorySlot` - 原始槽位位置
- `is_rotated: bool` - 是否已旋转

#### 方法
- `get_grid_value() -> int` - 获取物品的网格价值
- `can_rotate() -> bool` - 检查是否可以旋转
- `rotate_item()` - 旋转物品
- `reset_rotation()` - 重置旋转状态

## 测试

### 测试场景
项目包含一个完整的测试场景：`scene/launcher/test/grid_inventory_test.tscn`

### 测试功能
- 添加不同尺寸的测试物品
- 测试拖拽和旋转操作
- 验证预览功能
- 测试自动整理
- 边界情况处理

### 快捷键
- `1-4`: 快速添加不同类型的测试物品
- `8`: 旋转当前拖拽的物品
- `9`: 查看背包状态
- `0`: 清空背包

## 设计原则

### 性能优化
- 使用高效的网格索引系统
- 最小化每帧的计算量
- 优化碰撞检测算法

### 用户体验
- 流畅的拖拽操作
- 实时的视觉反馈
- 直观的交互方式

### 可扩展性
- 模块化的组件设计
- 灵活的配置选项
- 标准化的接口定义

## 注意事项

1. **物品尺寸**: 所有物品必须是矩形，不支持不规则形状
2. **网格对齐**: 物品必须完全对齐到网格，不支持部分占用
3. **旋转限制**: 1x1的物品旋转没有意义
4. **性能考虑**: 大量物品时注意性能优化

## 未来改进

- [ ] 支持不规则形状的物品
- [ ] 添加物品堆叠功能
- [ ] 实现物品分类系统
- [ ] 添加拖拽动画效果
- [ ] 支持多选操作
- [ ] 添加物品过滤功能

