## 标记组件 - 为实体提供空间标记和定位功能
## 该组件用于在游戏世界中标记重要位置、设置导航点或创建空间引用
## 通常作为其他系统的参考点使用，如AI导航、相机定位、特效生成等
## 应用场景：AI导航路径点、相机焦点位置、特效生成位置、交互热点标记、场景切换点
## 功能特性：轻量级空间标记、可扩展的标记类型、与其他系统的集成接口、运行时位置更新
## 架构设计：基于enum MarkerType的类型管理，提供统一的位置查询接口，支持标记信息的批量获取
## [br][b]编辑者:[/b] Sora
@tool
class_name CMarker
extends IComponent

## 标记类型枚举
## 定义不同类型的标记用途
enum MarkerType {
	TRANSITION     ## 场景切换点
}

var box_markers: Dictionary[StringName, BoxMarker] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_MARKER

## 组件初始化—设置标记的基本属性和注册到相关系统
## [param _owner]: 拥有此组件的实体
## [param _load_data]: 可选的加载数据
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)

	## TODO 设计标记的初始化
	for child in get_children():
		if child is BoxMarker:
			box_markers[child.name] = child

	initialize_complete.emit()
