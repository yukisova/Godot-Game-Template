## 左轮手枪的弹夹UI，在装备左轮手枪时，会在打开BrainUi时自动加入
## 逻辑类似体内寄生虫，子弹要一个一个上，但是目前与体内寄生虫不同，子弹有多种类型，如普通子弹，燃烧子弹，穿透子弹等
## [br][b]编辑者:[/b] Sora
@tool
extends EquipmentControl



## 子弹类型与纹理的映射
@export_group("纹理依赖")
## 空弹仓纹理
@export var empty_texture: Texture2D
## 中心点，旋转弹仓要用
@export var center_control: Control
## 子弹纹理 键为子弹序号，值为纹理
@export var bullet_clip_texture: Dictionary[int, Texture2D]
## 子弹发射完纹理
@export var bullet_clip_over_texture: Dictionary[int, Texture2D]


## 弹仓范围
@export var bullet_clip_range: float = 100:
	set(v):
		bullet_clip_range = v
		if is_node_ready():
			_change_bullet_clip_position()

@export_group("依赖节点")
## 退弹口
@export var eject_hole: TextureRect

## 修正弹仓位置
## 根据退弹口位置和弹仓数量，计算每个弹仓的位置（实现左轮弹仓的环形分布）
func _change_bullet_clip_position() -> void:
	var center_position = eject_hole.global_position + eject_hole.size / 2 
	var each_angle = 360.0 / bullet_clip_array.size()
	for i in bullet_clip_array.size():
		bullet_clip_array[i].global_position = Vector2.UP.rotated(deg_to_rad(each_angle * i)) * bullet_clip_range + center_position - bullet_clip_array[i].size / 2

## 初始化弹仓，此时已经成功绑定装备，可以获取到装备的子弹信息
func _initialize() -> void:
	# 1. 给每个弹仓设置子弹过滤器
	for i in binding_equipment.bullet_clip.size():
		var bullet_info = bullet_clip_array[i]
		bullet_info.bullet_fliter = bullet_fliter
		bullet_info.bullet_info_changed.connect(_on_bullet_info_changed)
		bullet_info.current_slot_type = binding_equipment.bullet_clip[i]
		bullet_info.current_slot_bullet_id = binding_equipment.bullet_clip_bullet_id[i]


	_change_bullet_clip_position()

func _on_bullet_info_changed(bullet_info: BulletClipSlot) -> void:
	var clip_index = bullet_clip_array.find(bullet_info)
	if clip_index == -1:
		printerr("子弹信息更新时，子弹信息不存在于弹仓中")
		return
	match bullet_info.current_slot_type:
		BulletClipSlot.BulletClipType.EMPTY:
			bullet_info.current_slot_texture = empty_texture
			## WARNING 这里的bullet_clip并非原生在ItemWeapon中，而是在未定义class_name的子类中声明的，需要确认与UI绑定的武器脚本是否有对应的变量
			binding_equipment.bullet_clip[clip_index] = BulletClipSlot.BulletClipType.EMPTY
			binding_equipment.bullet_clip_bullet_id[clip_index] = -1
		BulletClipSlot.BulletClipType.BULLET:
			bullet_info.current_slot_texture = bullet_clip_texture[bullet_info.current_slot_bullet_id]
			binding_equipment.bullet_clip[clip_index] = BulletClipSlot.BulletClipType.BULLET
			binding_equipment.bullet_clip_bullet_id[clip_index] = bullet_info.current_slot_bullet_id
		BulletClipSlot.BulletClipType.BULLET_OVER:
			bullet_info.current_slot_texture = bullet_clip_over_texture[bullet_info.current_slot_bullet_id]
			binding_equipment.bullet_clip[clip_index] = BulletClipSlot.BulletClipType.BULLET_OVER
			binding_equipment.bullet_clip_bullet_id[clip_index] = bullet_info.current_slot_bullet_id
