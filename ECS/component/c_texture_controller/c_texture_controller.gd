@tool
class_name CTextureController
extends IComponent

## 打包精灵
var packed_sprite: IPackedSprite

## 是否不可见
## 如果为true，则其下的所有IPackedSprite不会被渲染，只能通过类似手电筒着色器的方式进行观测，一般用于隐藏指定的实体，如幽灵
@export var unwatchable: bool:
	set(v):
		if Engine.is_editor_hint():
			unwatchable = v
			return
		## 在运行时仅允许unwatchable从false变为true
		if !unwatchable and v:
			unwatchable = v
			SMapData.current_level.entity_state_manager.hidding_entities.append(component_owner)

## 当前高度，用于辅助碰撞
var current_height: float = 16


func _enter_tree() -> void:
	component_name = ComponentName.C_TEXTURE_CONTROLLER

func _exit_tree() -> void:
	if Engine.is_editor_hint(): return

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	for i in get_children():
		if i is IPackedSprite:
			packed_sprite = i
			i.c_texture_controller = self
			
	# 验证纹理路径是否有效
	if packed_sprite:
		packed_sprite._initialize()
	
	initialize_completed.emit()

func _update(_delta: float):
	if packed_sprite:
		packed_sprite._update(_delta)

func _reset():
	if packed_sprite:
		packed_sprite._reset()

#region :存档系统:
func _save() -> Dictionary:
	return {}

## 加载数据
## [param _dict]: 要加载的数据字典
func _load(_dict: Dictionary):
	pass
#endregion
