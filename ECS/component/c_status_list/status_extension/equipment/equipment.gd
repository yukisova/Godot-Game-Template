## 装备系统扩展 - 管理角色的武器和装备节点
## 实现武器和装备的装载卸载，支持动态节点管理
## 提供攻击节点生命周期管理和信号驱动的装备变更通知
## [br][b]编辑者:[/b] Sora
class_name EquipmentExtension
extends StatusExtension
## 攻击节点变更信号
## [param item_weapon]: 新装备的武器，null表示卸载
signal attack_node_changed(item_weapon: ItemWeapon)

## 装备节点变更信号
## [param item_equipment]: 新装备的物品，null表示卸载
signal equipment_node_changed(item_equipment: Item)

@export var preload_weapon: WeaponNode
@export var preload_equipment: EquipmentNode

## 当前装备的武器
## 自动更新装备状态
var current_weapon: ItemWeapon:
	set(v):
		if current_weapon:
			current_weapon.is_equipped = false
		current_weapon = v
		if current_weapon:
			current_weapon.is_equipped = true

## 当前装备的攻击节点
## 设置时自动清理旧节点
var current_attack_node: WeaponNode:
	set(v):
		if current_attack_node:
			current_attack_node._deactivated()
			current_attack_node.queue_free()
			
		current_attack_node = v
		if current_attack_node:
			current_attack_node._activated()

## 当前装备的装备物品
## 设置时自动更新装备状态
var current_equipment: ItemEquipment:
	set(v):
		if current_equipment:
			current_equipment.is_equipped = false
		current_equipment = v
		if current_equipment:
			current_equipment.is_equipped = true

## 当前装备的装备节点
## 设置时自动清理旧节点
var current_equipment_node: EquipmentNode:
	set(v):
		if current_equipment_node:
			current_equipment_node._deactivated()
			current_equipment_node.queue_free()
		current_equipment_node = v
		if current_equipment_node:
			current_equipment_node._activated()

## 设置扩展类型为装备系统
func _enter_tree() -> void:
	extention_type = ExtensionType.EQUIPMENT

## 连接装备变更信号的处理方法
func _initialize():
	attack_node_changed.connect(_on_attack_node_changed)
	equipment_node_changed.connect(_on_equipment_node_changed)
	
	await c_status.component_owner.initialize_complete
	if preload_weapon:
		preload_weapon.c_status = c_status
		current_attack_node = preload_weapon
	if preload_equipment:
		preload_equipment.c_status = c_status
		current_equipment_node = preload_equipment

## 装备系统的持续效果处理
func _effect():
	pass

## 处理武器装备变更，创建或销毁攻击节点
## [param item_weapon]: 新装备的武器，null表示卸载
func _on_attack_node_changed(item_weapon: ItemWeapon):
	if item_weapon:
		current_weapon = item_weapon
		current_attack_node = item_weapon.equipment_node.instantiate()
		current_attack_node.c_status = c_status
		current_attack_node.set_hit_effect(item_weapon.hit_effect_list.duplicate_deep())

		var texture_controller: CTextureController = c_status.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
		if texture_controller:
			var right_part: PackedPart = texture_controller.packed_sprite.packed_sprite_editor.control_parts.get(&"Right", null)
			if right_part:
				right_part.add_child(current_attack_node)
				right_part.sprite = current_attack_node
			else:
				add_child(current_attack_node)
		current_attack_node.source_item = current_weapon
		current_attack_node._activated()
	else:
		current_weapon = null
		current_attack_node = null
	
## 处理普通装备变更，创建或销毁装备节点
## [param item_equipment]: 新装备的物品，null表示卸载
func _on_equipment_node_changed(item_equipment: ItemEquipment):
	if item_equipment:
		current_equipment = item_equipment
		current_equipment_node = item_equipment.equipment_node.instantiate()
		current_equipment_node.c_status = c_status
		var texture_controller: CTextureController = c_status.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
		if texture_controller:
			var left_part: PackedPart = texture_controller.packed_sprite.packed_sprite_editor.control_parts.get(&"Left", null)
			if left_part:
				left_part.add_child(current_equipment_node)
				left_part.sprite = current_equipment_node
			else:
				add_child(current_equipment_node)
		current_equipment_node.source_item = current_equipment
	else:
		current_equipment = null
		current_equipment_node = null

#region 存档系统

## 保存当前装备的武器和装备物品数据
func _save() -> Dictionary:
	return {
		extention_type:{
			"current_weapon": current_weapon.duplicate_deep() if current_weapon else null,
			"current_equipment": current_equipment.duplicate_deep() if current_equipment else null
		}
	}

## 从存档数据加载武器和装备物品
## [param _data]: 存档数据字典
func _load(_data: Dictionary):
	attack_node_changed.emit(_data["current_weapon"] as ItemWeapon)
	equipment_node_changed.emit(_data["current_equipment"] as ItemEquipment)

#endregion
