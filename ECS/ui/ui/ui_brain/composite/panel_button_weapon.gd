## 可以作为ButtonContainer原型的按钮组件，完整版需要等待Trait接口（4.6）的推出
class_name PanelButtonWeapon
extends PanelContainer

var binding_item: Item:
	set(v):
		binding_item = v
		if binding_item:
			texture.texture = binding_item.item_texture

## Weapon按钮对应的CStatusList
var target_c_status: CStatusList

@export var button: Button

@export var texture: TextureRect

var button_func: Callable = _binding_func

@export var args: Array[Variant]


## [param _args]: 参数数组: 可能的参数有
## 点击按钮： 拟以所使用的鼠标按键来判断武器装备在哪个手上。
func _binding_func(_context: Dictionary):
	var equipment_extension: EquipmentExtension = target_c_status.status_extension.get(StatusExtension.ExtensionType.EQUIPMENT)
	if binding_item is ItemWeapon:
		equipment_extension.attack_node_changed.emit(binding_item)
	elif binding_item is ItemEquipment:
		equipment_extension.equipment_node_changed.emit(binding_item)
	else:
		push_error("武器按钮: 绑定物品不是武器或装备")
