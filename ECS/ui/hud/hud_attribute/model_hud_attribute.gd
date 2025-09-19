## 状态Hud的数据模型
## [br][b]编辑者:[/b] Sora
extends UIModel

#region 信号
signal health_changed(value: float, max: float)
signal fitness_changed(value: float, max: float)
signal sound_changed(value: float, max: float)
signal weapon_changed(value: Texture2D)
signal equipment_changed(value: Texture2D)
#endregion

#region 属性
## 人物健康的状态
var health: float:
	set(v):
		health = v
		health_changed.emit(health, health_max)
var health_max: float:
	set(v):
		health_max = v
		health_changed.emit(health, health_max)

## 人物耐力的状态
var fitness: float:
	set(v):
		fitness = v
		fitness_changed.emit(fitness, fitness_max)
var fitness_max: float:
	set(v):
		fitness_max = v
		fitness_changed.emit(fitness, fitness_max)

## 人物声音的状态
var sound: float:
	set(v):
		sound = v
		sound_changed.emit(sound, sound_max)
var sound_max: float:
	set(v):
		sound_max = v
		sound_changed.emit(sound, sound_max)

## 人物武器的状态
var weapon: Texture2D:
	set(v):
		weapon = v
		weapon_changed.emit(weapon)
var equipment: Texture2D:
	set(v):
		equipment = v
		equipment_changed.emit(equipment)
#endregion

func _initialize(_context: Dictionary):
	var player_statics = _context["player_static"]

	var player_static = player_statics[0]
	var c_status_list = player_static.get_other_component(IComponent.ComponentName.C_STATUS_LIST) as CStatusList

	var health_status_info = c_status_list.status_list.get(SoraConstant.StatusEnum.Health)
	var fitness_status_info = c_status_list.status_list.get(SoraConstant.StatusEnum.Fitness)
	var equipment_extension = c_status_list.status_extension.get(StatusExtension.ExtensionType.EQUIPMENT)

	health = health_status_info.value
	health_max = health_status_info.max_value

	fitness = fitness_status_info.value
	fitness_max = fitness_status_info.max_value

	weapon = null if !equipment_extension.current_weapon else equipment_extension.current_weapon.item_texture
	equipment = null if !equipment_extension.current_equipment else equipment_extension.current_equipment.item_texture

	health_status_info.status_changed.connect(func(status_info: CStatusList.StatusInfo):
		health = status_info.value
		health_max = status_info.max_value
	)
	fitness_status_info.status_changed.connect(func(status_info: CStatusList.StatusInfo):
		fitness = status_info.value
		fitness_max = status_info.max_value
	)
	equipment_extension.attack_node_changed.connect(func(item_weapon: ItemWeapon): weapon = item_weapon.item_texture)
	equipment_extension.equipment_node_changed.connect(func(item_equipment: ItemEquipment): equipment = item_equipment.item_texture)
