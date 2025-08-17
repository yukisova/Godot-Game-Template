## 装备系统扩展 - 管理角色的武器和装备节点
##
## 该扩展实现了角色的装备系统，负责武器和装备的装载、卸载和节点管理。
## 提供统一的装备接口，支持武器攻击节点和装备功能节点的动态管理。
##
## 核心功能：
## - 武器系统：管理武器装备和攻击节点的生命周期
## - 装备系统：管理普通装备和功能节点的挂载
## - 节点管理：自动处理装备节点的创建和销毁
## - 状态同步：维护装备的装备状态标记
##
## 主要特性：
## - 动态节点实例化和挂载机制
## - 武器攻击节点的状态和效果传递
## - 装备更换的无缝切换处理
## - 信号驱动的装备变更通知
##
## 使用场景：
## - 角色武器的装备和卸载
## - 护甲、饰品等装备的管理
## - 装备属性和技能的动态加载
## - 装备系统的数据持久化
##
## 架构设计：
## - 继承自 [StatusExtension] 基类
## - 使用信号系统处理装备变更事件
## - 支持 [ItemWeapon] 和 [ItemEquipment] 的统一管理
## - 集成 [WeaponAttackNode] 的攻击节点系统
##
## [br][b]编辑者:[/b] Sora
class_name EquipmentExtension
extends StatusExtension
## 
## 攻击节点变更信号
## 
## 当武器装备发生变化时发出，用于更新攻击系统。
## [param item_weapon]: 新装备的武器，类型为 [ItemWeapon]，null表示卸载
signal attack_node_changed(item_weapon: ItemWeapon)

## 装备节点变更信号
## 
## 当普通装备发生变化时发出，用于更新装备系统。
## [param item_equipment]: 新装备的物品，类型为 [Item]，null表示卸载
signal equipment_node_changed(item_equipment: Item)

## 当前装备的武器
## 
## 当前角色装备的武器物品，设置时自动更新装备状态，类型为 [ItemWeapon]。
var current_weapon: ItemWeapon:
	set(v):
		if current_weapon:
			current_weapon.is_equipped = false
		current_weapon = v
		if current_weapon:
			current_weapon.is_equipped = true

## 当前装备的攻击节点
## 
## 当前武器对应的攻击节点实例，设置时自动清理旧节点，类型为 [WeaponAttackNode]。
var current_attack_node: WeaponAttackNode:
	set(v):
		if current_attack_node:
			current_attack_node.queue_free()
		current_attack_node = v

## 当前装备的装备物品
## 
## 当前角色装备的装备物品，设置时自动更新装备状态，类型为 [ItemEquipment]。
var current_equipment: ItemEquipment:
	set(v):
		if current_equipment:
			current_equipment.is_equipped = false
		current_equipment = v
		if current_equipment:
			current_equipment.is_equipped = true

## 当前装备的装备节点
## 
## 当前装备对应的功能节点实例，设置时自动清理旧节点，类型为 [Node2D]。
var current_equipment_node: Node2D:
	set(v):
		if current_equipment_node:
			current_equipment_node.queue_free()
		current_equipment_node = v

## 节点初始化（重写方法）
## 
## 设置扩展类型为装备系统。
func _enter_tree() -> void:
	extention_type = ExtensionType.EQUIPMENT

## 装备扩展初始化（重写方法）
## 
## 连接装备变更信号的处理方法。
func _initialize():
	attack_node_changed.connect(_on_attack_node_changed)
	equipment_node_changed.connect(_on_equipment_node_changed)

## 装备扩展效果（重写方法）
## 
## 装备系统的持续效果，当前无需特殊处理。
func _effect():
	pass

## 攻击节点变更处理
## 
## 处理武器装备的变更，创建或销毁对应的攻击节点。
## [param item_weapon]: 新装备的武器，类型为 [ItemWeapon]，null表示卸载
func _on_attack_node_changed(item_weapon: ItemWeapon):
	if item_weapon:
		current_weapon = item_weapon
		current_attack_node = item_weapon.weapon_node.instantiate()
		current_attack_node.c_status = c_status
		current_attack_node.hit_effect_list = item_weapon.hit_effect_list.duplicate_deep()
		add_child(current_attack_node)
	else:
		current_weapon = null
		current_attack_node = null
	
## 装备节点变更处理
## 
## 处理普通装备的变更，创建或销毁对应的装备节点。
## [param item_equipment]: 新装备的物品，类型为 [ItemEquipment]，null表示卸载
func _on_equipment_node_changed(item_equipment: ItemEquipment):
	if item_equipment:
		current_equipment = item_equipment
		current_equipment_node = item_equipment.equipment_node.instantiate()
		current_equipment_node.c_status = c_status
		add_child(current_equipment_node)
	else:
		current_equipment = null
		current_equipment_node = null

#region 存档系统

## 保存装备数据（重写方法）
## 
## 保存当前装备的武器和装备物品数据。
## [br][br][b]返回:[/b] [Dictionary] 包含装备数据的字典
func _save() -> Dictionary:
	return {
		extention_type:{
			"current_weapon": current_weapon.duplicate_deep() if current_weapon else null,
			"current_equipment": current_equipment.duplicate_deep() if current_equipment else null
		}
	}

## 加载装备数据（重写方法）
## 
## 从存档数据加载武器和装备物品。
## [param _data]: 存档数据字典，类型为 [Dictionary]
func _load(_data: Dictionary):
	attack_node_changed.emit(_data["current_weapon"] as ItemWeapon)
	equipment_node_changed.emit(_data["current_equipment"] as ItemEquipment)

#endregion
