## 装备UI
## 当玩家装备武器与装备的时候，武器对应的特殊UI
## [br][b]编辑者:[/b] Sora
@tool
class_name EquipmentControl
extends Control

# 弹夹仓的纹理，共6个，对应6发装弹
@export var bullet_clip_array: Array[BulletClipSlot]

## 装填子弹时的过滤器，根据物品的NickName前缀来判断物品是否可以装入弹仓
@export var bullet_fliter: String

