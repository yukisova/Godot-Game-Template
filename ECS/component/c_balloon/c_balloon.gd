## 气泡组件 - 管理实体相关的UI浮动效果和视觉反馈
##
## 该组件用于管理实体的各种浮动UI元素，如对话气泡、状态提示、伤害数字等。
## 主要基于 [Tween] 动画系统实现各种视觉效果的播放和控制。
##
## 应用场景：
## - 对话气泡显示
## - 状态提示气泡
## - 伤害/治疗数值显示
## - 交互提示UI
## - 其他浮动式UI反馈
##
## 功能特性：
## - 基于 [Tween] 的平滑动画
## - 命名的组合UI管理
## - 淡入淡出效果
## - 可扩展的动画效果
##
## 架构设计：
## - 基于 [Dictionary] 的UI控件管理
## - 使用 [StringName] 作为UI标识
## - 提供多种动画效果接口
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CBalloon
extends IComponent

## 组合UI字典
## 
## 存储所有气泡UI控件，通过名称进行索引和管理。
## 键为UI名称（[StringName]），值为对应的 [Control] 控件。
var composites_dict: Dictionary[StringName, Control] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_BALLOON

## 组件初始化
## 
## 收集所有子节点中的 [Control] 控件作为气泡UI元素。
## [param _owner]: 拥有此组件的实体，类型为 [IEntity]
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 收集所有Control类型的子节点
	for control: Control in get_children():
		composites_dict[control.name] = control
		# 初始时隐藏所有气泡UI
		control.visible = false
	
	initialize_complete.emit()

## 目标气泡淡入效果
## 
## 使指定名称的气泡UI以淡入效果显示。
## [param target_composite]: 目标气泡UI的名称，类型为 [StringName]
func _target_fade_in(target_composite: StringName):
	var composite = composites_dict.get(target_composite)
	if composite:
		composite.visible = true
		composite.modulate.a = 0.0
		
		# 创建淡入动画
		var tween = create_tween()
		tween.tween_property(composite, "modulate:a", 1.0, 0.3)
	else:
		push_warning("气泡组件: 未找到目标气泡UI - ", target_composite)

## 目标气泡淡出效果
## 
## 使指定名称的气泡UI以淡出效果隐藏。
## [param target_composite]: 目标气泡UI的名称，类型为 [StringName]
func _target_fade_out(target_composite: StringName):
	var composite = composites_dict.get(target_composite)
	if composite:
		# 创建淡出动画
		var tween = create_tween()
		tween.tween_property(composite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): composite.visible = false)
	else:
		push_warning("气泡组件: 未找到目标气泡UI - ", target_composite)

## 隐藏所有气泡
## 立即隐藏所有气泡UI元素
func hide_all_balloons():
	for composite in composites_dict.values():
		composite.visible = false

## 显示指定气泡
## 
## 立即显示指定名称的气泡UI。
## [param target_composite]: 目标气泡UI的名称，类型为 [StringName]
func show_balloon(target_composite: StringName):
	var composite = composites_dict.get(target_composite)
	if composite:
		composite.visible = true
		composite.modulate.a = 1.0
