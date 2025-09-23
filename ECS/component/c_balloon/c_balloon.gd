@tool
class_name CBalloon
extends IComponent

var composites_dict: Dictionary[StringName, Control] = {}

func _enter_tree() -> void:
	component_name = ComponentName.C_BALLOON

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	for control: Control in get_children():
		composites_dict[control.name] = control
		control.visible = false
	
	initialize_completed.emit()

func _target_fade_in(target_composite: StringName):
	var composite = composites_dict.get(target_composite)
	if composite:
		composite.visible = true
		composite.modulate.a = 0.0
		
		var tween = create_tween()
		tween.tween_property(composite, "modulate:a", 1.0, 0.3)
	else:
		push_warning("气泡组件: 未找到目标气泡UI - ", target_composite)

func _target_fade_out(target_composite: StringName):
	var composite = composites_dict.get(target_composite)
	if composite:
		var tween = create_tween()
		tween.tween_property(composite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): composite.visible = false)
	else:
		push_warning("气泡组件: 未找到目标气泡UI - ", target_composite)

func hide_all_balloons():
	for composite in composites_dict.values():
		composite.visible = false

func show_balloon(target_composite: StringName):
	var composite = composites_dict.get(target_composite)
	if composite:
		composite.visible = true
		composite.modulate.a = 1.0
