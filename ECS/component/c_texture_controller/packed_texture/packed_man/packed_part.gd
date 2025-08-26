## [b]打包纹理部件类[/b]
##
## 用于管理角色身体各个部位的纹理组件。[br]
## 支持编辑器实时预览和运行时动态纹理管理。
## [br][b]编辑者:[/b] Sora


@tool
class_name PackedPart
extends Node2D
## [b]默认纹理资源[/b]
## 
## 部件的默认纹理，设置时会自动更新Sprite2D的纹理显示。[br]
## 在[color=orange]编辑器模式[/color]下支持实时预览，[color=green]运行时[/color]支持动态切换。
@export var default_texture: Texture2D:
	set(value):
		if value == null:
			return
		default_texture = value
		# 编辑器模式下立即更新纹理显示
		if sprite == null:
			sprite = Sprite2D.new()
			add_child(sprite)
			sprite.texture = default_texture
@export_range(1,2) var hframes: int:
	set(value):
		hframes = value
		if sprite is Sprite2D:
			sprite.hframes = value



## [b]内部Sprite2D节点[/b]
## 
## 实际显示纹理的[color=blue]Sprite2D[/color]节点，由本类自动创建和管理。[br]
## [color=red]无需手动操作[/color]，纹理更新通过[code]default_texture[/code]属性进行。
@export var sprite: Node2D:
	set(value):
		if value == null:
			return
		if sprite != null:
			sprite.queue_free()
		sprite = value

## [b]初始化方法[/b]
## 
## 在[color=green]运行时模式[/color]下初始化Sprite2D节点并设置默认纹理。[br]
## [color=orange]编辑器模式[/color]下跳过初始化，避免与编辑器预览冲突。
func _ready() -> void:
	# 编辑器模式下跳过初始化
	if Engine.is_editor_hint(): 
		return

#region 武器动作
@export var packed_sprite_editor: PackedSpriteEditor

@export_group("武器动作", "x_")
## 将武器的握法固定在-90度
@export var x_竖握: bool = false:
	set(value):
		x_竖握 = value
		if x_竖握:
			sprite.rotation = deg_to_rad(-90)
		else:
			sprite.rotation = 0

## 将武器的握法固定在90度
@export var x_反握: bool = false:
	set(value):
		x_反握 = value
		if !is_node_ready():
			return
		if x_反握:
			sprite.rotation = deg_to_rad(90)
		else:
			sprite.rotation = 0

## 武器挥舞的纹理反转(flip_h)
var x_纹理反转: bool:
	set(value):
		x_纹理反转 = value
		if !is_node_ready():
			return
		if sprite is Sprite2D:
			sprite.flip_h = x_纹理反转
		elif sprite is EquipmentNode:
			sprite.fixed_flip_h(x_纹理反转)

## 默认是逆时针挥舞，如果为true则顺时针挥舞
@export var x_挥舞方向: bool
	
## 武器的强制高度偏移
@export var x_高度偏移: float
	
## 武器挥舞的轨道偏移，对应pse的椭圆
@export var x_轨道偏移: Vector2 = Vector2(0, 0)
	
## 武器挥舞的自转偏移(相对于当前的朝向,分为顺时针和逆时针)
@export var x_自转偏移: float
	
## 武器挥舞的公转偏移(相对于玩家body的朝向,分为顺时针和逆时针)
## 单位为度
@export var x_公转偏移: float


@export var x_突刺进度: float

var x_基础位置: Vector2
var x_基础长轴: float
var x_基础短轴: float
var x_基础轨道旋转: float
var x_基础纹理旋转: float
var x_基础方向: Vector2
var x_身体z轴: int
 
#endregion


func _fixed_transform() -> void:
	var angle = x_基础轨道旋转 + deg_to_rad(x_公转偏移)
	var ellipse_x = (x_基础长轴 + x_轨道偏移.x) * cos(angle)
	var ellipse_y = (x_基础短轴 + x_轨道偏移.y) * sin(angle)

	position = Vector2(ellipse_x, ellipse_y) + x_基础位置 + Vector2(0, x_高度偏移) + x_突刺进度 * x_基础方向
	var rotation_offset = deg_to_rad(x_自转偏移)
	if !x_竖握 and !x_反握:
		if x_纹理反转:
			rotation_offset = -deg_to_rad(x_自转偏移)
		rotation = x_基础纹理旋转 + rotation_offset
	else:
		if x_纹理反转:
			rotation_offset = -deg_to_rad(x_自转偏移)
		rotation = rotation_offset

func _update(_delta: float) -> void:
	_fixed_transform()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_fixed_transform()

func back_to_default() -> void:
	if sprite is EquipmentNode:
		return
	elif sprite:
		sprite.queue_free()
	sprite = Sprite2D.new()
	sprite.texture = default_texture
	add_child(sprite)
