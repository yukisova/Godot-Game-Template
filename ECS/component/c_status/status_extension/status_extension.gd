## @editing: Sora [br]
## @describe: 状态扩展基类 - 为状态组件提供复杂状态管理的扩展机制
## 
## 该抽象类为状态组件提供可扩展的高级功能模块，如背包系统、Buff/Debuff管理、
## 装备系统等。通过扩展系统实现状态数据的模块化管理和功能复用。
## 
## 扩展类型：
## - 背包扩展：物品存储和管理系统
## - 临时效果扩展：Buff/Debuff和时效性状态管理
## - 装备扩展：装备穿戴和属性加成系统
## 
## 设计模式：
## - 策略模式：不同扩展类型提供不同的状态处理策略
## - 组合模式：多个扩展可以组合使用
## - 观察者模式：扩展状态变化可以被监听
## 
## 功能特性：
## - 类型安全的扩展分类
## - 统一的生命周期管理
## - 可配置的效果系统
## - 与状态组件无缝集成
@abstract class_name StatusExtension
extends Node2D

## 扩展类型枚举
## 定义不同类型的状态扩展，用于分类和管理
enum ExtensionType {
	INVENTORY,     ## 背包系统扩展
	BUFF_LIST, ## Buff/Debuff系统扩展
	EQUIPMENT, ## 装备系统扩展
}

## 扩展类型标识
## 标识当前扩展的具体类型，用于运行时类型检查和分派
var extention_type: ExtensionType

## 扩展初始化
## 扩展被添加到状态组件时调用，用于设置初始状态和配置
@abstract func _initialize()

## 扩展效果执行
## 扩展的核心逻辑实现，定期或在特定条件下执行
@abstract func _effect()

## 扩展状态保存
## 将扩展的当前状态保存为字典格式，用于存档系统
## @return: 包含扩展状态的字典
func _save_extension() -> Dictionary:
	return {
		"extension_type": extention_type,
		"custom_data": _get_custom_save_data()
	}

## 扩展状态加载
## 从存档数据恢复扩展状态
## @param data: 包含扩展状态的字典
func _load_extension(data: Dictionary):
	if data.has("extension_type"):
		extention_type = data.extension_type
	if data.has("custom_data"):
		_set_custom_save_data(data.custom_data)

## 获取自定义存档数据
## 子类重写此方法来保存特定的扩展数据
## @return: 自定义数据字典
func _get_custom_save_data() -> Dictionary:
	return {}

## 设置自定义存档数据
## 子类重写此方法来恢复特定的扩展数据
## @param data: 自定义数据字典
func _set_custom_save_data(_data: Dictionary):
	pass
