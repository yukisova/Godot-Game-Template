## @editing: Sora [br]
## @describe: 纹理组件 - 管理实体的视觉表现和动画系统
## 
## 该组件负责管理实体的所有视觉相关元素，包括静态纹理、动画精灵、
## 动画播放器和动画状态机。支持多种精灵类型和动画控制方式。
## 
## 支持的精灵类型：
## - AnimatedSprite2D：帧动画精灵
## - Sprite2D：静态精灵
## - PackedSprite：自定义打包精灵
## 
## 功能特性：
## - 统一的纹理管理接口
## - 动画播放器集成
## - 动画状态机支持
## - 纹理切换系统
## - 可扩展的精灵类型支持
@tool
class_name C_Texture
extends IComponent

@export_subgroup("纹理配置")
## 纹理节点路径
## 指向实体下的精灵节点，支持AnimatedSprite2D、Sprite2D和PackedSprite
@export_node_path("AnimatedSprite2D","Sprite2D","PackedSprite") var texture_path: NodePath

## 动画播放器（可选）
## 用于播放复杂的动画序列和过渡效果
@export var animation_player: AnimationPlayer

## 动画状态机（可选）
## 提供基于状态的动画控制和自动切换
@export var animation_tree: AnimationTree

## 精灵切换列表
## 预定义的纹理字典，用于运行时切换不同的精灵纹理
@export var sprite_change_list: Dictionary[String, Texture2D]

func _enter_tree() -> void:
	component_name = ComponentName.c_texture

## 组件初始化
## 验证纹理路径和动画组件的有效性
## @param _owner: 拥有此组件的实体
func _initialize(_owner: IEntity):
	super._initialize(_owner)
	
	# 验证纹理路径是否有效
	if not has_node(texture_path):
		push_warning("纹理组件: 纹理路径无效 - ", texture_path)

## 获取纹理节点
## 返回当前配置的精灵节点实例
## @return: 精灵节点对象，可能为AnimatedSprite2D、Sprite2D或PackedSprite
func _get_texture():	
	return get_node(texture_path)

## 切换纹理
## 根据键名从切换列表中更换纹理
## @param texture_key: 纹理切换列表中的键名
func change_texture(texture_key: String):
	if texture_key in sprite_change_list:
		var sprite_node = _get_texture()
		if sprite_node and sprite_node.has_method("set_texture"):
			sprite_node.set_texture(sprite_change_list[texture_key])
	else:
		push_warning("纹理组件: 未找到纹理键 - ", texture_key)

#region 存档系统
## 保存纹理组件数据
## @return: 纹理组件的存档数据字典
func _save_as() -> Dictionary:
	# TODO: 实现当前纹理状态和动画状态的存档逻辑
	return {}

## 加载纹理组件数据
## @param data: 纹理组件的存档数据
func _load_by(_data: Dictionary):
	# TODO: 实现纹理状态和动画状态的读档逻辑
	pass
#endregion
