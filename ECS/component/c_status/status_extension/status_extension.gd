## 状态扩展基类 - 为状态组件提供复杂状态管理的扩展机制
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
##
## 架构设计：
## - 抽象基类，需要子类实现具体功能
## - 基于 [enum ExtensionType] 的类型管理
## - 与 [CStatus] 组件集成
## - 支持存档和加载机制
##
## [br][b]编辑者:[/b] Sora
@abstract class_name StatusExtension
extends Node2D

## 扩展类型枚举
## 
## 定义不同类型的状态扩展，用于分类和管理。
enum ExtensionType {
	INVENTORY,     ## 背包系统扩展 - 物品存储和管理
	BUFF_LIST,     ## Buff/Debuff系统扩展 - 临时状态效果管理
	EQUIPMENT,     ## 装备系统扩展 - 装备穿戴和属性加成
}

## 扩展类型标识
## 
## 标识当前扩展的具体类型，用于运行时类型检查和分派。
var extention_type: ExtensionType

## 绑定的状态组件
## 
## 扩展将通过此组件访问和修改实体状态，类型为 [CStatus]。
var c_status: CStatus

## 扩展初始化（抽象方法）
## 
## 扩展被添加到状态组件时调用，用于设置初始状态和配置。
@abstract func _initialize()

## 扩展效果执行（抽象方法）
## 
## 扩展的核心逻辑实现，定期或在特定条件下执行。
@abstract func _effect()

## 扩展状态保存（抽象方法）
## 
## 将扩展的当前状态保存为字典格式。
## [br][br][b]返回:[/b] [Dictionary] 包含扩展状态数据的字典
@abstract func _save() -> Dictionary

## 扩展状态加载（抽象方法）
## 
## 从存档数据恢复扩展状态。
## [param _data]: 包含扩展状态的字典
@abstract func _load(_data: Dictionary)
