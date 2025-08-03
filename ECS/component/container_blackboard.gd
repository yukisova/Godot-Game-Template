## @editing: Sora [br]
## @describe: 针对components容器的黑板变量，在entity被代码自动创建时，用来确定entity的基本信息
## FIXME 这是一个很重要的类，但是没有时间进行完善了,在此进行记录
class_name ContainerBlackboard
extends Node2D

signal data_updated(key: StringName)

var data: Dictionary = {}  # 数据存储核心

# 数据写入（带类型检查）
func set_value(key: Variant, value, type: Variant.Type = TYPE_NIL) -> bool:
	if type != TYPE_NIL and typeof(value) != type:
		push_error("没有指定黑板变量类型: " + key)
		return false
	data[key] = {"value": value, "type": type}
	data_updated.emit(key) # 触发数据更新信号
	return true

# 数据读取（支持默认值）
func get_value(key: Variant, default = null):
	return data.get(key, {"value": default}).value

## 使用黑板来更好的初始化实体
func initilize_data_parse(context: Dictionary):
	for key in context.keys():
		match key:
			"global_position":
				owner.global_position = context[key]
			"":
				continue
			_:
				set_value(key, context[key], typeof(context[key]))
			
