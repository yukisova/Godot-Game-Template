## @editing: Sora [br]
## @describe: 容器黑板 - 组件级数据共享和实体初始化管理器
## 
## 该类为组件提供局部的数据共享机制，主要用于实体在运行时的动态创建和初始化。
## 作为实体级别的数据容器，支持类型安全的数据存储和组件间的数据通信。
## 
## 核心功能：
## - 实体初始化数据解析
## - 组件间数据共享
## - 类型安全的数据存储
## - 数据变化事件通知
## 
## 应用场景：
## - 动态创建实体时的参数传递
## - 组件间的临时数据共享
## - 实体状态的运行时配置
## - 策略模式中的参数存储
## 
## TODO: 这是一个核心类，需要进一步完善和优化架构设计
class_name ContainerBlackboard
extends Node2D

## 数据更新信号
## 当黑板中的数据发生变化时触发，传递变化的键名
signal data_updated(key: StringName)

## 数据存储核心
## 存储所有黑板数据，每个条目包含值和类型信息
var data: Dictionary = {}

## 设置黑板数据
## 支持类型检查的数据写入，确保数据类型的一致性
## @param key: 数据键名
## @param value: 数据值
## @param type: 期望的数据类型，TYPE_NIL表示不进行类型检查
## @return: 写入是否成功
func set_value(key: Variant, value, type: Variant.Type = TYPE_NIL) -> bool:
	# 类型检查：如果指定了类型且不匹配，则报错
	if type != TYPE_NIL and typeof(value) != type:
		push_error("容器黑板: 数据类型不匹配，键名: " + str(key) + "，期望类型: " + str(type) + "，实际类型: " + str(typeof(value)))
		return false
	
	# 存储数据和类型信息
	data[key] = {"value": value, "type": type}
	data_updated.emit(key) # 触发数据更新信号
	return true

## 获取黑板数据
## 支持默认值的数据读取，如果键不存在则返回默认值
## @param key: 数据键名
## @param default: 默认值，当键不存在时返回
## @return: 数据值或默认值
func get_value(key: Variant, default = null):
	return data.get(key, {"value": default}).value

## 检查数据是否存在
## @param key: 数据键名
## @return: 数据是否存在
func has_value(key: Variant) -> bool:
	return data.has(key)

## 移除黑板数据
## @param key: 要移除的数据键名
## @return: 移除是否成功
func remove_value(key: Variant) -> bool:
	if data.has(key):
		data.erase(key)
		data_updated.emit(key)
		return true
	return false

## 实体初始化数据解析
## 使用上下文字典对实体进行配置和初始化
## @param context: 包含初始化数据的字典
func initilize_data_parse(context: Dictionary):
	for key in context.keys():
		match key:
			"global_position":
				# 特殊处理：直接设置实体位置
				owner.global_position = context[key]
			"":
				# 空键名跳过
				continue
			_:
				# 一般数据：存储到黑板中，供组件使用
				set_value(key, context[key], typeof(context[key]))

## 获取所有数据的字典副本
## @return: 包含所有数据的字典
func get_all_data() -> Dictionary:
	var result = {}
	for key in data.keys():
		result[key] = data[key].value
	return result

## 清空所有数据
func clear_data():
	data.clear()
	data_updated.emit("")
			
