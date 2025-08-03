##@editing:	Sora
##@describe:	用于打开其他界面的按钮
@tool
class_name LinkageButton
extends BaseButton

enum LinkMode { 
	creation, ## 创造新的目标ui，
	linkage ## 聚焦于指定的已经存在的目标组件
	}
@export var link_mode: LinkMode:
	set(v):
		link_mode = v
		notify_property_list_changed()
		

@export var generator_scene: PackedScene
@export var g_scene_parent: Node

@export var link_control: Control

## 在creation模式下最终所要联系的目标
var linkage_target: CreationCanvas = null


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
