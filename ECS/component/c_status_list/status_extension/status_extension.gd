## 状态扩展基类 - 为状态组件提供扩展机制
## 提供背包、Buff/Debuff、装备系统等高级功能模块
## 支持类型安全分类、生命周期管理和存档加载
## [br][b]编辑者:[/b] Sora
@abstract class_name StatusExtension
extends Node2D

## 扩展类型枚举
## 定义不同类型的状态扩展
enum ExtensionType {
	INVENTORY,     ## 背包系统扩展
	BUFF_LIST,     ## Buff/Debuff系统扩展
	EQUIPMENT,     ## 装备系统扩展
}

## 扩展类型标识
## 标识当前扩展的具体类型
var extention_type: ExtensionType

## 绑定的状态组件
## 扩展通过此组件访问实体状态
var c_status: CStatusList

## 扩展被添加到状态组件时调用
@abstract func _initialize()

## 扩展的核心逻辑实现
@abstract func _effect()

## 将扩展状态保存为字典格式
@abstract func _save() -> Dictionary

## 从存档数据恢复扩展状态
## [param _data]: 包含扩展状态的字典
@abstract func _load(_data: Dictionary)
