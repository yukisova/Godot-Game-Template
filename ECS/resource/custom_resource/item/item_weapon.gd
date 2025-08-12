## 武器物品类
## 包含武器的使用子弹名称，使用的攻击模式逻辑，在由玩家获得武器之后，可以进行进一步的
class_name ItemWeapon
extends Item

var weapon_node: PackedScene ## 武器攻击所使用的节点，会搭载至c_status下的equipment节点下

func _equip():
	pass

func _unequip():
	pass
