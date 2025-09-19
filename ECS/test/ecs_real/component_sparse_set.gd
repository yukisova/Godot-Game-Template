## 组件稀疏集合 - 专为ECS组件管理设计的特化稀疏集合
## 继承自SparseSet，专门用于存储和管理特定类型的组件数据
## 特性：类型安全的组件存储、支持组件数据的批量操作、内存对齐优化、组件生命周期管理
## 用途：作为ECS系统中Archetype的组件存储后端，实现高效的组件查询和迭代
## [br][b]编辑者:[/b] Sora
class_name ComponentSparseSet
extends "sparse_set.gd"

## 组件数据数组 - 存储实际的组件实例，与密集数组保持同步
## 每个索引位置对应dense数组中相同位置的实体的组件数据
var components: Array = []

## 组件类型信息
var component_type: String = ""
var component_class: Script = null

## 构造函数 - 初始化组件稀疏集合
## [param _component_type]: 组件类型名称
## [param _component_class]: 组件类的脚本引用
## [param initial_capacity]: 初始容量
func _init(_component_type: String, _component_class: Script = null, initial_capacity: int = 1024):
	super._init(initial_capacity)
	component_type = _component_type
	component_class = _component_class
	# 预留组件数组空间
	if initial_capacity > 0:
		components.resize(initial_capacity)
		components.resize(0)  # 恢复为0大小但保持容量

## 为实体添加组件
## [param entity_id]: 实体ID
## [param component]: 要添加的组件实例
## [return]: 如果成功添加返回true，否则返回false
func add_component(entity_id: int, component: Variant) -> bool:
	if entity_id < 0:
		push_error("ComponentSparseSet: 实体ID不能为负数")
		return false
	
	# 如果实体已有该组件，更新组件数据
	if contains(entity_id):
		var index = get_index(entity_id)
		components[index] = component
		return true
	
	# 扩展稀疏数组容量
	if entity_id >= sparse.size():
		var old_size = sparse.size()
		sparse.resize(entity_id + 1)
		for i in range(old_size, sparse.size()):
			sparse[i] = -1
	
	# 确保数组有足够空间
	if size >= dense.size():
		dense.resize(max(dense.size() * 2, size + 1))
		components.resize(dense.size())
	
	# 添加实体和组件
	dense[size] = entity_id
	components[size] = component
	sparse[entity_id] = size
	size += 1
	
	return true

## 移除实体的组件
## [param entity_id]: 要移除组件的实体ID
## [return]: 如果成功移除返回true，否则返回false
func remove_component(entity_id: int) -> bool:
	if not contains(entity_id):
		return false
	
	var dense_index = sparse[entity_id]
	var last_entity = dense[size - 1]
	var last_component = components[size - 1]
	
	# Swap-and-pop操作
	dense[dense_index] = last_entity
	components[dense_index] = last_component
	sparse[last_entity] = dense_index
	
	# 清理被移除的实体
	sparse[entity_id] = -1
	components[size - 1] = null  # 释放引用
	size -= 1
	
	return true

## 获取实体的组件
## [param entity_id]: 实体ID
## [return]: 对应的组件实例，如果不存在返回null
func get_component(entity_id: int) -> Variant:
	if not contains(entity_id):
		return null
	
	var index = sparse[entity_id]
	return components[index]

## 获取指定索引位置的组件
## [param index]: 在密集数组中的索引
## [return]: 对应位置的组件实例
func get_component_at(index: int) -> Variant:
	if index < 0 or index >= size:
		push_error("ComponentSparseSet: 索引越界，索引=%d, 大小=%d" % [index, size])
		return null
	return components[index]

## 获取指定索引位置的实体和组件
## [param index]: 在密集数组中的索引
## [return]: 包含entity_id和component的字典
func get_entity_component_at(index: int) -> Dictionary:
	if index < 0 or index >= size:
		push_error("ComponentSparseSet: 索引越界，索引=%d, 大小=%d" % [index, size])
		return {}
	
	return {
		"entity_id": dense[index],
		"component": components[index]
	}

## 批量获取所有实体和组件对
## [return]: 包含所有实体-组件对的数组
func get_all_entity_components() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	result.resize(size)
	
	for i in range(size):
		result[i] = {
			"entity_id": dense[i],
			"component": components[i]
		}
	
	return result

## 获取所有组件的直接引用（用于高效批量处理）
## [return]: 组件数组的引用
func get_components_array() -> Array:
	return components

## 遍历所有组件并执行回调函数
## [param callback]: 回调函数，接受(entity_id: int, component: Variant, index: int)参数
func for_each(callback: Callable):
	for i in range(size):
		callback.call(dense[i], components[i], i)

## 遍历所有组件并执行回调函数（只传递组件）
## [param callback]: 回调函数，接受(component: Variant)参数
func for_each_component(callback: Callable):
	for i in range(size):
		callback.call(components[i])

## 根据条件筛选实体
## [param predicate]: 筛选条件函数，接受(entity_id: int, component: Variant)参数，返回bool
## [return]: 符合条件的实体ID数组
func filter_entities(predicate: Callable) -> Array[int]:
	var result: Array[int] = []
	
	for i in range(size):
		if predicate.call(dense[i], components[i]):
			result.append(dense[i])
	
	return result

## 根据条件查找第一个匹配的实体
## [param predicate]: 查找条件函数
## [return]: 第一个匹配的实体ID，如果没找到返回-1
func find_entity(predicate: Callable) -> int:
	for i in range(size):
		if predicate.call(dense[i], components[i]):
			return dense[i]
	return -1

## 更新实体的组件（如果存在）
## [param entity_id]: 实体ID
## [param new_component]: 新的组件数据
## [return]: 如果成功更新返回true，如果实体不存在该组件返回false
func update_component(entity_id: int, new_component: Variant) -> bool:
	if not contains(entity_id):
		return false
	
	var index = sparse[entity_id]
	components[index] = new_component
	return true

## 批量更新组件
## [param updater]: 更新函数，接受(entity_id: int, component: Variant)参数，返回新的组件
func batch_update(updater: Callable):
	for i in range(size):
		var new_component = updater.call(dense[i], components[i])
		if new_component != null:
			components[i] = new_component

## 清空集合（重写父类方法）
func clear():
	super.clear()
	# 清理组件引用
	for i in range(components.size()):
		components[i] = null

## 压缩数组（重写父类方法）
func compact():
	super.compact()
	# 调整组件数组大小
	if size < components.size():
		components.resize(size)

## 克隆组件稀疏集合
## [return]: 新的ComponentSparseSet实例
func clone() -> ComponentSparseSet:
	var new_set = ComponentSparseSet.new(component_type, component_class, sparse.size())
	
	# 复制数据
	new_set.sparse = sparse.duplicate()
	new_set.dense = dense.duplicate()
	new_set.components = components.duplicate()
	new_set.size = size
	
	return new_set

## 获取组件类型信息
## [return]: 包含类型信息的字典
func get_type_info() -> Dictionary:
	return {
		"component_type": component_type,
		"component_class": component_class,
		"entity_count": size,
		"has_script_type": component_class != null
	}

## 验证数据结构完整性（重写父类方法）
func validate() -> bool:
	if not super.validate():
		return false
	
	# 检查组件数组大小
	if components.size() < dense.size():
		push_error("ComponentSparseSet: 组件数组大小不足")
		return false
	
	# 检查组件数组中的数据完整性
	for i in range(size):
		if components[i] == null:
			push_warning("ComponentSparseSet: 发现null组件，实体ID: %d" % dense[i])
	
	return true

## 获取内存使用统计（重写父类方法）
func get_memory_info() -> Dictionary:
	var base_info = super.get_memory_info()
	base_info["component_memory_estimate"] = components.size() * 8  # 引用大小估算
	base_info["total_memory_bytes"] += base_info["component_memory_estimate"]
	return base_info

## 调试输出（重写父类方法）
func print_debug_info():
	print("=== ComponentSparseSet Debug Info ===")
	print("Component Type: %s" % component_type)
	print("Size: %d" % size)
	print("Sparse capacity: %d" % sparse.size())
	print("Dense capacity: %d" % dense.size())
	print("Components capacity: %d" % components.size())
	
	print("Entity-Component pairs:")
	for i in range(min(size, 5)):  # 只显示前5个
		print("  [%d] Entity_%d -> %s" % [i, dense[i], str(components[i])])
	if size > 5:
		print("  ... (%d more)" % (size - 5))
	
	var memory_info = get_memory_info()
	print("Memory efficiency: %.2f%%" % (memory_info.memory_efficiency * 100))
	print("====================================")

## 静态工厂方法 - 创建特定类型的组件稀疏集合
static func create_for_type(type_name: String, type_class: Script = null) -> ComponentSparseSet:
	return ComponentSparseSet.new(type_name, type_class)
