## 纹理组件 - 管理实体的视觉表现和动画系统
## 负责统一的纹理管理、动画播放器集成和动画状态机支持
## 提供可扩展的精灵类型支持和运行时纹理切换机制
## [br][b]编辑者:[/b] Sora
@tool
class_name CTextureController
extends IComponent

var packed_sprite: IPackedSprite

## 是否可见
## 如果为false，则其下的所有PackedSprite不会被渲染，只能通过手电筒着色器的方式进行观测
@export var unwatchable: bool

func _enter_tree() -> void:
	component_name = ComponentName.C_TEXTURE_CONTROLLER

## 验证纹理路径和动画组件有效性
## [param _owner]: 拥有此组件的实体
## [param _load_data]: 可选的加载数据
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	for i in get_children():
		if i is IPackedSprite:
			packed_sprite = i
			i.c_texture_controller = self
			if unwatchable:
				SMapData.current_level.hidden_packed_sprites.append(i)
			
	# 验证纹理路径是否有效
	if packed_sprite:
		packed_sprite._initialize()
	
	initialize_complete.emit()

func _update(_delta: float):
	if packed_sprite:
		packed_sprite._update(_delta)

func _reset():
	packed_sprite._reset()

#region :存档系统:
func _save() -> Dictionary:
	return {}

## 加载数据
## [param _dict]: 要加载的数据字典
func _load(_dict: Dictionary):
	pass

func _exit_tree() -> void:
	if Engine.is_editor_hint(): return
	if unwatchable:
		SMapData.current_level.hidden_packed_sprites.erase(packed_sprite)
#endregion
