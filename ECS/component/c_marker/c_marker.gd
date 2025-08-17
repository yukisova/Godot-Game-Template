## 标记组件 - 为实体提供空间标记和定位功能
##
## 该组件用于在游戏世界中标记重要位置、设置导航点或创建空间引用。
## 通常作为其他系统的参考点使用，如AI导航、相机定位、特效生成等。
##
## 应用场景：
## - AI导航路径点
## - 相机焦点位置
## - 特效生成位置
## - 交互热点标记
## - 场景切换点
##
## 功能特性：
## - 轻量级空间标记
## - 可扩展的标记类型
## - 与其他系统的集成接口
## - 运行时位置更新
##
## 架构设计：
## - 基于 [enum MarkerType] 的类型管理
## - 提供统一的位置查询接口
## - 支持标记信息的批量获取
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CMarker
extends IComponent

## 标记类型枚举
## 
## 定义不同类型的标记用途。
enum MarkerType {
	NAVIGATION,    ## 导航标记 - 用于AI寻路和导航系统
	CAMERA_FOCUS,  ## 相机焦点 - 用于相机跟踪和定位
	EFFECT_SPAWN,  ## 特效生成点 - 用于特效系统的生成位置
	INTERACTION,   ## 交互点 - 用于交互系统的热点标记
	TRANSITION     ## 场景切换点 - 用于场景切换和传送
}

## 标记类型
## 
## 定义该标记的用途和类型，参见 [enum MarkerType]。
@export var marker_type: MarkerType = MarkerType.NAVIGATION

## 标记标识
## 
## 用于唯一标识该标记的字符串，建议使用有意义的命名。
@export var marker_id: String = ""

## 标记描述
## 
## 对该标记用途的文字描述，用于编辑器显示和调试。
@export var description: String = ""

func _enter_tree() -> void:
	component_name = ComponentName.C_MARKER

## 组件初始化
## 
## 设置标记的基本属性和注册到相关系统。
## [param _owner]: 拥有此组件的实体，类型为 [IEntity]
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 如果没有设置标记ID，使用实体名称作为默认ID
	if marker_id.is_empty():
		marker_id = component_owner.name + "_marker"
	
	initialize_complete.emit()

## 获取标记位置
## 
## [br][br][b]返回:[/b] [Vector2] 标记在世界坐标系中的位置
func get_marker_position() -> Vector2:
	return component_owner.global_position

## 设置标记位置
## 
## [param new_position]: 新的世界坐标位置
func set_marker_position(new_position: Vector2):
	component_owner.global_position = new_position

## 获取标记信息
## 
## [br][br][b]返回:[/b] [Dictionary] 包含标记所有信息的字典，包含id、type、position、description、entity字段
func get_marker_info() -> Dictionary:
	return {
		"id": marker_id,
		"type": marker_type,
		"position": get_marker_position(),
		"description": description,
		"entity": component_owner
	}
