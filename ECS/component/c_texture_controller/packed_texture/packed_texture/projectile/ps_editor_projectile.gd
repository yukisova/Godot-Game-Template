@tool
class_name PSEditorProjectile
extends PackedSpriteEditor

## 当前子弹的高度，根据它来判断纹理与地面的距离，进而判断是否与目标碰撞
@export_range(0,1) var current_range_ratio: float:
	set(value):
		current_range_ratio = value
		if is_node_ready():
			_change_height(value)

#region 工具按钮
@export var fixed_body_y: int:
	set(v):
		fixed_body_y = v
		if Engine.is_editor_hint():
			fixed_packed_sprite()

@export_tool_button("快速校准位置") var quick_fixed = fixed_packed_sprite

## 根据设定的精灵躯干的参数，快速校准精灵各个部位的位置
func fixed_packed_sprite():
	var body = control_parts.get(&"Main", null).get_parent() as Node2D
	body.position = Vector2(0, fixed_body_y)
#endregion

@export var path_node: Curve2D 

func _change_height(value: float):
	control_parts.get(&"Main").position.y = path_node.sample(0, value).y

## 子弹落地的情况
## 1. 销毁
## 2. 变为地雷类的子弹，有另外的逻辑
func _body_on_floor():
	pass

func _initialize():
	super()
	_change_height(current_range_ratio)

func _update(_delta: float):
	pass
