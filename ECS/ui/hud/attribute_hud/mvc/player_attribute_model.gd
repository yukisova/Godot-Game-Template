## 玩家属性数据模型 - MVC架构中的Model层
## 负责管理和封装玩家的状态数据，包括血量、体力、装备等信息
## 提供统一的数据访问接口，隔离底层组件系统的复杂性
## 通过信号机制通知数据变化，支持响应式UI更新
## [br][b]编辑者:[/b] Sora
class_name PlayerAttributeModel
extends RefCounted

# 数据变化信号
## 血量变化信号
## [param current_value]: 当前血量
## [param max_value]: 最大血量
signal health_changed(current_value: float, max_value: float)

## 体力变化信号  
## [param current_value]: 当前体力
## [param max_value]: 最大体力
signal fitness_changed(current_value: float, max_value: float)

## 武器装备变化信号
## [param weapon_texture]: 武器贴图，null表示无装备
signal weapon_changed(weapon_texture: Texture2D)

## 装备变化信号
## [param equipment_texture]: 装备贴图，null表示无装备
signal equipment_changed(equipment_texture: Texture2D)

# 私有成员变量
var _c_status_list: CStatusList
var _equipment_extension: EquipmentExtension
var _is_initialized: bool = false

# 公共属性访问器
## 获取当前血量值
var health_value: float:
	get:
		if !_is_initialized:
			return 0.0
		var health_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Health)
		return health_info.value if health_info else 0.0

## 获取最大血量值
var health_max_value: float:
	get:
		if !_is_initialized:
			return 0.0
		var health_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Health)
		return health_info.max_value if health_info else 0.0

## 获取当前体力值
var fitness_value: float:
	get:
		if !_is_initialized:
			return 0.0
		var fitness_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Fitness)
		return fitness_info.value if fitness_info else 0.0

## 获取最大体力值  
var fitness_max_value: float:
	get:
		if !_is_initialized:
			return 0.0
		var fitness_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Fitness)
		return fitness_info.max_value if fitness_info else 0.0

## 获取当前武器贴图
var weapon_texture: Texture2D:
	get:
		if !_is_initialized or !_equipment_extension:
			return null
		var weapon = _equipment_extension.current_weapon
		return weapon.item_texture if weapon else null

## 获取当前装备贴图
var equipment_texture: Texture2D:
	get:
		if !_is_initialized or !_equipment_extension:
			return null
		var equipment = _equipment_extension.current_equipment  
		return equipment.item_texture if equipment else null

## 初始化模型，绑定玩家数据源
## [param player_index]: 玩家索引，默认为0
func initialize(player_index: int = 0) -> bool:
	# 获取玩家实体
	var player_entity = SMainController._get_player_info_by_index(player_index)
	if !player_entity:
		push_error("PlayerAttributeModel: 无法获取玩家实体 index=%d" % player_index)
		return false
		
	# 获取状态列表组件
	_c_status_list = player_entity.get_other_component(IComponent.ComponentName.C_STATUS_LIST) as CStatusList
	if !_c_status_list:
		push_error("PlayerAttributeModel: 玩家实体缺少状态列表组件")
		return false
		
	# 获取装备扩展组件
	_equipment_extension = _c_status_list.get_status_extension(StatusExtension.ExtensionType.EQUIPMENT) as EquipmentExtension
	if !_equipment_extension:
		push_warning("PlayerAttributeModel: 未找到装备扩展组件，装备功能将不可用")
	
	# 绑定信号监听
	_bind_signals()
	
	_is_initialized = true
	return true

## 释放资源和取消信号连接
func cleanup() -> void:
	if _c_status_list:
		_unbind_status_signals()
		
	if _equipment_extension:
		_unbind_equipment_signals()
		
	_c_status_list = null
	_equipment_extension = null
	_is_initialized = false

## 绑定所有信号监听
func _bind_signals() -> void:
	_bind_status_signals()
	_bind_equipment_signals()

## 绑定状态变化信号
func _bind_status_signals() -> void:
	if !_c_status_list:
		return
		
	# 绑定血量变化信号
	var health_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Health)
	if health_info:
		health_info.status_changed.connect(_on_health_status_changed)
		
	# 绑定体力变化信号
	var fitness_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Fitness)
	if fitness_info:
		fitness_info.status_changed.connect(_on_fitness_status_changed)

## 绑定装备变化信号
func _bind_equipment_signals() -> void:
	if !_equipment_extension:
		return
		
	_equipment_extension.attack_node_changed.connect(_on_weapon_changed)
	_equipment_extension.equipment_node_changed.connect(_on_equipment_changed)

## 解绑状态信号
func _unbind_status_signals() -> void:
	if !_c_status_list:
		return
		
	var health_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Health)
	if health_info and health_info.status_changed.is_connected(_on_health_status_changed):
		health_info.status_changed.disconnect(_on_health_status_changed)
		
	var fitness_info = _c_status_list.status_list.get(SoraConstant.StatusEnum.Fitness)
	if fitness_info and fitness_info.status_changed.is_connected(_on_fitness_status_changed):
		fitness_info.status_changed.disconnect(_on_fitness_status_changed)

## 解绑装备信号
func _unbind_equipment_signals() -> void:
	if !_equipment_extension:
		return
		
	if _equipment_extension.attack_node_changed.is_connected(_on_weapon_changed):
		_equipment_extension.attack_node_changed.disconnect(_on_weapon_changed)
		
	if _equipment_extension.equipment_node_changed.is_connected(_on_equipment_changed):
		_equipment_extension.equipment_node_changed.disconnect(_on_equipment_changed)

# 信号回调方法
## 血量状态变化回调
func _on_health_status_changed(status_info: CStatusList.StatusInfo) -> void:
	health_changed.emit(status_info.value, status_info.max_value)

## 体力状态变化回调
func _on_fitness_status_changed(status_info: CStatusList.StatusInfo) -> void:
	fitness_changed.emit(status_info.value, status_info.max_value)

## 武器变化回调
func _on_weapon_changed(item_weapon: ItemWeapon) -> void:
	var texture = item_weapon.item_texture if item_weapon else null
	weapon_changed.emit(texture)

## 装备变化回调
func _on_equipment_changed(item_equipment: ItemEquipment) -> void:
	var texture = item_equipment.item_texture if item_equipment else null
	equipment_changed.emit(texture)

## 检查模型是否已正确初始化
func is_initialized() -> bool:
	return _is_initialized

## 获取模型状态摘要（用于调试）
func get_debug_info() -> Dictionary:
	return {
		"is_initialized": _is_initialized,
		"has_status_list": _c_status_list != null,
		"has_equipment_extension": _equipment_extension != null,
		"health": {"value": health_value, "max": health_max_value},
		"fitness": {"value": fitness_value, "max": fitness_max_value},
		"has_weapon": weapon_texture != null,
		"has_equipment": equipment_texture != null
	}
