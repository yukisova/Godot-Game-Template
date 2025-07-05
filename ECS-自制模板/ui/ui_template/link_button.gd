## 用于打开其他界面的按钮
@tool
class_name LinkageButton
extends BaseButton

enum LinkMode { creation, linkage }
@export var link_mode: LinkMode:
	set(v):
		link_mode = v
		notify_property_list_changed()
		

@export var generator_scene: PackedScene
@export var g_scene_parent: Node

@export var link_control: Control

## 最终所要联系的目标
var linkage_target: Node = null


## 外部触发之后所要执行的逻辑
func _execute():
	match link_mode:
		LinkMode.linkage:
			pass
		LinkMode.creation:
			linkage_target = generator_scene.instantiate()
			g_scene_parent.add_child(linkage_target)
			
			
func _validate_property(property: Dictionary) -> void:
	match link_mode:
		LinkMode.linkage:
			if property.name == "generator_scene" or property.name == "g_scene_parent":
				property.usage = PROPERTY_USAGE_NO_EDITOR
		LinkMode.creation:
			if property.name == "link_control":
				property.usage = PROPERTY_USAGE_NO_EDITOR
