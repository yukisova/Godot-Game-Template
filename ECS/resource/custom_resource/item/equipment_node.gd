# 装备节点， 
## 与attackNode相对，是玩家一般情况下放在左手处的装备，
## 武器是子类，但是因为时间关系，两者分开区分
## 装备定义：无法实现攻击效果，但可以用来在某些情况下实现辅助的作用
## 例如: 
## 1. 手电筒，可以用来照亮黑暗区域，在加强之后可以让敌人短时间致盲
## 2. 火把，可以用来照亮黑暗区域，或者丢出，在合适的情况下可以实现点燃
## 3. 盾牌，可以用来抵挡敌人的攻击，或者用来格挡敌人的攻击
@tool
@abstract class_name EquipmentNode
extends Node2D

## 是否允许根据玩家的朝向来改变纹理的朝向
@export var rotate_able: bool
## 在flip_h后，纹理有可能出现偏移，为此需要在节点内提前设定好纹理修正后的position
@export var flip_h_offset_false: Vector2 = Vector2.ZERO
@export var flip_h_offset_true: Vector2 = Vector2.ZERO
@export var texture: Sprite2D

var c_status: CStatusList

func fixed_flip_h(is_flip: bool):
	if texture:
		texture.flip_h = is_flip
		texture.position = flip_h_offset_false if not is_flip else flip_h_offset_true

## 装备触发效果的方法，可以被子类重写
func _trigger_effect(..._args):
	pass

## 装备的触发效果关闭的方法
func _trigger_effect_finished(..._args):
	pass

## 装备的激活方法
func _activated():
	pass
