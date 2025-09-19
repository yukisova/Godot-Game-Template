## Sparse Set - ECS架构核心数据结构
## 稀疏集合是ECS系统中用于高效存储和查询实体-组件关系的关键数据结构
## 特性：O(1)插入删除查找、内存紧凑、迭代友好、支持稳定索引
## 设计原理：使用稀疏数组+密集数组的双数组结构实现高效的稀疏数据管理
## [br][b]编辑者:[/b] Sora
class_name SparseSet
extends RefCounted

## 稀疏数组 - 索引为实体ID，值为在密集数组中的位置
## 用于快速查找实体是否存在于集合中，并获取其在密集数组中的索引
var sparse: Array[int] = []

## 密集数组 - 存储实际的实体ID，保证内存连续性
## 用于高效遍历所有存在的实体，支持缓存友好的访问模式
var dense: Array[int] = []

## 当前存储的实体数量
var size: int = 0

## 构造函数 - 初始化稀疏集合
## [param initial_capacity]: 初始容量大小，用于预分配内存
func _init(initial_capacity: int = 1024):
	sparse.resize(initial_capacity)
	# 将稀疏数组全部初始化为无效值
	sparse.fill(-1)
	# 预留空间但不改变大小
	if initial_capacity > 0:
		dense.resize(initial_capacity)
		dense.resize(0)  # 恢复为0大小但保持容量

## 检查实体是否存在于集合中
## [param entity_id]: 要检查的实体ID
## [return]: 如果实体存在返回true，否则返回false
func contains(entity_id: int) -> bool:
	# 边界检查
	if entity_id < 0 or entity_id >= sparse.size():
		return false
	
	var dense_index = sparse[entity_id]
	# 检查稀疏数组中的值是否有效，并且对应的密集数组位置确实存储了该实体
	return dense_index >= 0 and dense_index < size and dense[dense_index] == entity_id

## 向集合中插入实体
## [param entity_id]: 要插入的实体ID
## [return]: 如果成功插入返回true，如果实体已存在返回false
func insert(entity_id: int) -> bool:
	if entity_id < 0:
		push_error("SparseSet: 实体ID不能为负数")
		return false
	
	# 如果实体已存在，直接返回false
	if contains(entity_id):
		return false
	
	# 扩展稀疏数组容量
	if entity_id >= sparse.size():
		var old_size = sparse.size()
		sparse.resize(entity_id + 1)
		# 将新增的部分初始化为无效值
		for i in range(old_size, sparse.size()):
			sparse[i] = -1
	
	# 确保密集数组有足够空间
	if size >= dense.size():
		dense.resize(max(dense.size() * 2, size + 1))
	
	# 在密集数组末尾添加实体ID
	dense[size] = entity_id
	# 在稀疏数组中记录该实体在密集数组中的位置
	sparse[entity_id] = size
	size += 1
	
	return true

## 从集合中移除实体
## [param entity_id]: 要移除的实体ID
## [return]: 如果成功移除返回true，如果实体不存在返回false
func remove(entity_id: int) -> bool:
	if not contains(entity_id):
		return false
	
	var dense_index = sparse[entity_id]
	var last_entity = dense[size - 1]
	
	# Swap-and-pop操作：将要删除的元素与最后一个元素交换，然后删除最后一个元素
	dense[dense_index] = last_entity
	sparse[last_entity] = dense_index
	
	# 将被移除实体的稀疏数组位置标记为无效
	sparse[entity_id] = -1
	size -= 1
	
	return true

## 获取指定索引位置的实体ID
## [param index]: 密集数组中的索引
## [return]: 对应位置的实体ID
func get_entity(index: int) -> int:
	if index < 0 or index >= size:
		push_error("SparseSet: 索引越界，索引=%d, 大小=%d" % [index, size])
		return -1
	return dense[index]

## 获取实体在密集数组中的索引
## [param entity_id]: 实体ID
## [return]: 在密集数组中的索引，如果不存在返回-1
func get_index(entity_id: int) -> int:
	if not contains(entity_id):
		return -1
	return sparse[entity_id]

## 清空集合
func clear():
	# 只需要重置size，不需要清空数组内容
	# 这样可以保持已分配的内存供后续使用
	for i in range(size):
		var entity_id = dense[i]
		if entity_id < sparse.size():
			sparse[entity_id] = -1
	size = 0

## 获取当前存储的实体数量
func get_size() -> int:
	return size

## 检查集合是否为空
func is_empty() -> bool:
	return size == 0

## 获取密集数组的直接引用（用于高效遍历）
## [return]: 密集数组的引用
func get_dense_array() -> Array[int]:
	return dense

## 迭代器支持 - 获取所有实体ID
## [return]: 包含所有实体ID的数组（仅包含有效部分）
func get_entities() -> Array[int]:
	var result: Array[int] = []
	result.resize(size)
	for i in range(size):
		result[i] = dense[i]
	return result

## 压缩稀疏数组 - 移除尾部未使用的空间
func compact():
	if sparse.is_empty():
		return
	
	# 找到最大的实体ID
	var max_entity_id = -1
	for i in range(size):
		max_entity_id = max(max_entity_id, dense[i])
	
	# 如果没有实体，清空稀疏数组
	if max_entity_id == -1:
		sparse.clear()
		return
	
	# 调整稀疏数组大小到刚好能容纳最大实体ID
	if max_entity_id + 1 < sparse.size():
		sparse.resize(max_entity_id + 1)

## 获取内存使用统计信息
## [return]: 包含内存使用信息的字典
func get_memory_info() -> Dictionary:
	return {
		"sparse_capacity": sparse.size(),
		"dense_capacity": dense.size(), 
		"entity_count": size,
		"sparse_memory_bytes": sparse.size() * 4,  # int大小
		"dense_memory_bytes": dense.size() * 4,
		"total_memory_bytes": (sparse.size() + dense.size()) * 4,
		"memory_efficiency": float(size) / float(sparse.size()) if sparse.size() > 0 else 0.0
	}

## 验证数据结构的完整性（调试用）
## [return]: 如果数据结构有效返回true，否则返回false
func validate() -> bool:
	# 检查大小边界
	if size < 0 or size > dense.size():
		push_error("SparseSet: 无效的size值")
		return false
	
	# 检查密集数组中的每个实体
	for i in range(size):
		var entity_id = dense[i]
		if entity_id < 0 or entity_id >= sparse.size():
			push_error("SparseSet: 密集数组中存在无效实体ID: %d" % entity_id)
			return false
		
		if sparse[entity_id] != i:
			push_error("SparseSet: 稀疏数组和密集数组不一致")
			return false
	
	# 检查稀疏数组中的有效索引
	for entity_id in range(sparse.size()):
		var dense_index = sparse[entity_id]
		if dense_index >= 0:
			if dense_index >= size or dense[dense_index] != entity_id:
				push_error("SparseSet: 稀疏数组指向无效位置")
				return false
	
	return true

## 调试输出
func print_debug_info():
	print("=== SparseSet Debug Info ===")
	print("Size: %d" % size)
	print("Sparse capacity: %d" % sparse.size()) 
	print("Dense capacity: %d" % dense.size())
	
	print("Dense array content:")
	for i in range(min(size, 10)):  # 只显示前10个
		print("  [%d] = %d" % [i, dense[i]])
	if size > 10:
		print("  ... (%d more)" % (size - 10))
	
	print("Sparse array (non-empty entries):")
	var count = 0
	for entity_id in range(sparse.size()):
		if sparse[entity_id] >= 0:
			print("  entity_%d -> dense[%d]" % [entity_id, sparse[entity_id]])
			count += 1
			if count >= 10:
				break
	
	var memory_info = get_memory_info()
	print("Memory efficiency: %.2f%%" % (memory_info.memory_efficiency * 100))
	print("========================")
