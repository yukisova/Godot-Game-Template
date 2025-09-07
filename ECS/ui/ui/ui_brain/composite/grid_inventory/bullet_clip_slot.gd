## 弹仓
@tool
class_name BulletClipSlot
extends PanelContainer

signal bullet_info_changed(new_bullet_info: BulletClipSlot)

## 弹仓状态，EMPTY为空，BULLET为已经填入子弹，BULLET_OVER为子弹已经发射，需要清理
enum BulletClipType {
	EMPTY = 0,
	BULLET = 1,
	BULLET_OVER = -1,
}

@export var current_slot_type: BulletClipType:
	set(v):
		current_slot_type = v

## 子弹ID，-1为空弹仓，-2为初始状态
var current_slot_bullet_id: int = -2:
	set(v):
		if current_slot_bullet_id == v:
			return
		current_slot_bullet_id = v
		## 根据更新的子弹ID，更改纹理，但纹理需要由EquipmentControl传递过来
		bullet_info_changed.emit(self)

## 由EquipmentControl传递过来的子弹过滤器
var bullet_fliter: String

var current_slot_texture: Texture2D:
	set(v):
		current_slot_texture = v
		if is_node_ready():
			_change_texture(v)

## 改变当前弹仓的纹理
## [param v: Texture2D] 新的纹理
func _change_texture(v: Texture2D) -> void:
	if current_texture:
		current_texture.queue_free()
	if v == null:
		return
	current_texture = TextureRect.new()
	current_texture.texture = v
	add_child(current_texture)

var current_texture: TextureRect

## 尝试填装子弹
## [param item: DragableItem] 要填装的物品
## [br][br][b]返回:[/b] [bool] 是否成功添加
func try_reload_bullet(item: DragableItem) -> bool:
	var binding_item = item.binding_item
	if current_slot_type == BulletClipType.EMPTY:
		if binding_item is ItemBullet and binding_item.item_nick_name.begins_with(bullet_fliter):
			current_slot_type = BulletClipType.BULLET
			## 根据NickName中的数字，判断子弹ID，通过setter中的方法来触发bullet_id_changed信号，改变纹理
			current_slot_bullet_id = binding_item.item_nick_name.trim_prefix(bullet_fliter).to_int()
			return true
	return false

## 尝试清空子弹
## [br][br][b]返回:[/b] [bool] 是否成功清空
func try_clear_bullet():
	if current_slot_type == BulletClipType.BULLET or current_slot_type == BulletClipType.BULLET_OVER:
		current_slot_type = BulletClipType.EMPTY
		current_slot_bullet_id = -1
		return true
	return false

## 判断当前弹仓是否为空
## [br][br][b]返回:[/b] [bool] 是否为空
func is_empty() -> bool:
	return current_slot_type == BulletClipType.EMPTY
