@tool
class_name PSEditorProjectile
extends PackedSpriteEditor

#region 工具按钮
@export var fixed_body_y: int:
	set(v):
		fixed_body_y = v
		if Engine.is_editor_hint():
			fixed_packed_sprite()

@export_tool_button("快速校准位置") var quick_fixed = fixed_packed_sprite

## 根据设定的精灵躯干的参数，快速校准精灵各个部位的位置
func fixed_packed_sprite():
	texture_lib.position = Vector2(0, fixed_body_y)
#endregion

## 子弹落地的情况
## 1. 销毁
## 2. 变为地雷类的子弹，有另外的逻辑
func _body_on_floor():
	pass

func _initialize():
	super()
	texture_lib.position.y = main_part.c_texture_controller.current_height

func _update(_delta: float):
	var latest_height = main_part.c_texture_controller.current_height
	texture_lib.position.y = latest_height
