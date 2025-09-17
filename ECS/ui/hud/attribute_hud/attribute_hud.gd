## 玩家属性HUD - 显示角色基础信息和快捷操作界面
## 该HUD集成了多个玩家相关的UI元素：时间循环系统的时钟显示、背包抽屉式快捷栏
## 物品拖拽和交互功能、玩家状态的实时更新
## 主要功能：实时显示游戏内时间、提供背包物品的快速访问、支持物品的拖拽操作
## UI特性：抽屉式背包展开/收起动画、可拖拽的物品图标、响应式布局适配
## 架构设计：继承自 [IHud] 基类，与 [FixedEntity] 的玩家实体绑定，集成 [InventoryExtension] 背包系统
## [br][b]编辑者:[/b] Sora
extends IHud

@export var health_bar: ProgressBar
@export var sound_bar: ProgressBar
@export var fitness_bar: ProgressBar
@export var left_hand_texture: TextureRect
@export var right_hand_texture: TextureRect

var binding_entitys: Array
var c_status_list: CStatusList

func _refresh():
	pass

func _initialize():
	var player_static_1 = SMainController._get_player_info_by_index(0)
	c_status_list = player_static_1.get_other_component(IComponent.ComponentName.C_STATUS_LIST) as CStatusList
	if player_static_1 != null:
		if c_status_list != null:
			var health_status_info: CStatusList.StatusInfo = c_status_list.status_list[SoraConstant.StatusEnum.Health]
			health_bar.max_value = health_status_info.max_value
			health_bar.value = health_status_info.value
			health_status_info.status_changed.connect(_on_health_status_changed)

			var fitness_status_info: CStatusList.StatusInfo = c_status_list.status_list[SoraConstant.StatusEnum.Fitness]
			fitness_bar.max_value = fitness_status_info.max_value
			fitness_bar.value = fitness_status_info.value
			fitness_status_info.status_changed.connect(_on_fitness_status_changed)
	
	var equipment: EquipmentExtension = c_status_list.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
	if equipment:
		var current_weapon = equipment.current_weapon
		var current_equipment = equipment.current_equipment
		if current_weapon:
			left_hand_texture.texture = current_weapon.item_texture
		if current_equipment:
			right_hand_texture.texture = current_equipment.item_texture
		equipment.equipment_node_changed.connect(_on_equipment_node_changed)
		equipment.attack_node_changed.connect(_on_attack_node_changed)
		
func _on_equipment_node_changed(item_equipment: ItemEquipment):
	right_hand_texture.texture = item_equipment.item_texture

func _on_attack_node_changed(item_weapon: ItemWeapon):
	left_hand_texture.texture = item_weapon.item_texture
		
func _on_health_status_changed(status_info: CStatusList.StatusInfo):
	health_bar.value = status_info.value

func _on_fitness_status_changed(status_info: CStatusList.StatusInfo):
	fitness_bar.value = status_info.value


	
