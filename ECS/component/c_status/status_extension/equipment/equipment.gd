## @editing: Sora [br]
## @describe: 装备系统扩展
## 装备系统下搭载着可以实现装备效果的节点，目前的主要应用为远程武器
class_name EquipmentExtension
extends StatusExtension

## 
signal attack_node_changed(new_attack_node: Node2D)
signal equipment_node_changed(new_equipment_node: Node2D)

var current_attack_node: Node2D ## 当前装备的攻击节点
var current_equipment_node: Node2D ## 当前装备的装备节点

## 节点初始化
## 设置扩展类型为背包
func _enter_tree() -> void:
	extention_type = ExtensionType.EQUIPMENT

func _initialize():
	pass

func _effect():
	pass
