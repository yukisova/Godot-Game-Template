extends ItemWeapon

## 弹巢内的子弹状态: 0为空弹仓，1为子弹，-1为子弹已发射
@export var bullet_clip: Array[BulletClipSlot.BulletClipType]:
	set(v):
		bullet_clip = v
		bullet_clip.resize(current_bullet_clip_num)

## 弹巢内的子弹ID: -1为空弹仓，0-5为子弹ID
@export var bullet_clip_bullet_id: Array[int]:
	set(v):
		bullet_clip_bullet_id = v
		bullet_clip_bullet_id.resize(current_bullet_clip_num)

## 当前撞针指向的弹仓
var current_index: int = 0

## 当前弹容量等级
var current_bullet_clip_num: BulletClipNumLevel = BulletClipNumLevel.L1

enum BulletClipNumLevel {
	L1 = 6,
	L2 = 8,
	L3 = 12
}
