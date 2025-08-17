## 纹理组件 - 管理实体的视觉表现和动画系统
##
## 该组件负责管理实体的所有视觉相关元素，包括静态纹理、动画精灵、
## 动画播放器和动画状态机。支持多种精灵类型和动画控制方式。
##
## 支持的精灵类型：
##
## 功能特性：
## - 统一的纹理管理接口
## - 动画播放器集成
## - 动画状态机支持
## - 纹理切换系统
## - 可扩展的精灵类型支持
##
## 架构设计：
## - 基于 [NodePath] 的灵活节点引用
## - 支持 [AnimationPlayer] 和 [AnimationTree] 的集成
## - 提供运行时纹理切换机制
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CTextureController
extends IComponent

@export_subgroup("纹理配置")
## 纹理节点路径
## 
## 指向实体下的精灵节点，[IPackedSprite]。
@export var packed_sprite: IPackedSprite

func _enter_tree() -> void:
	component_name = ComponentName.C_TEXTURE_CONTROLLER

## 组件初始化
## 
## 验证纹理路径和动画组件的有效性。
## [param _owner]: 拥有此组件的实体，类型为 [IEntity]
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 验证纹理路径是否有效
	if packed_sprite:
		push_error("纹理组件: 没有关联包装精灵")
	
	initialize_complete.emit()


#region :存档系统:
func _save() -> Dictionary:
	return {}

## 加载数据
## 
## 在 [method _initialize] 初始化时进行调用，但需要等待 [signal initialize_complete] 信号触发后才能进行加载。
## [param _dict]: 要加载的数据字典
func _load(_dict: Dictionary):
	pass
#endregion
