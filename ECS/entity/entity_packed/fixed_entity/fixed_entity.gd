@tool
class_name FixedEntity
extends IEntity

# 初始化数据
## 1. 在编辑器编辑场景或者工厂批量生成实体时设置的初始化数据
@export var init_data: Dictionary[IComponent.ComponentName, ContainerBlackboardData]

# 实体原生存在标志
## 标识实体是否为静态地图中的原生对象, 如果是通过工厂模式批量生成的，则该标志为false
var is_entity_origin_exist: bool

# 接口组件字典
## 需要在原本实体的基础之上加装新的组件，则需要将新的组件挂载在接口组件字典中，并且需要通过remote_transform节点挂载在原本实体上
## 可以避免在编辑器编辑场景时，直接编辑模板内的子节点
var list_interface_components: Dictionary[int, IComponent] = {}

## 实体注册
func _setup():
	## 1. entity_initialzable为true时，代表本实体是在游戏循环内创建的，可以不考虑等待信号，直接初始化
	## 2. entity_initialzable为false时，代表本实体是在地图加载前创建的，需要等待地图加载完毕的信号，所以需要连接信号并进行等待
	if Main.entity_initialzable:
		_initialize()
	else:
		SSignalBus.entity_initialize_started.connect(_initialize.bind(true))

## 实体初始化
## [param need_disconnect]: 是否需要断开信号(地图加载前创建的实体)
func _initialize(need_disconnect: bool = false):
	## 1. 绑定初始化数据
	await _init_data_binding(SoraEvent.fixed_dictionary(self, init_data))

	## 2. 检查是否有存档数据，如果有则加载存档数据
	## 2.1 fixed_entity在保存游戏的时候会存储其相关信息
	var load_data_for_components = {}
	if SLoadAndSave.current_saved:
		load_data_for_components = _load_by(SLoadAndSave.current_saved)
	
	## 3. 初始化两套组件容器
	for interface in get_children():
		if (interface is IComponent):
			interface._initialize(self, load_data_for_components.get(interface.component_name, {}))
			list_interface_components[interface.component_name] = interface
	
	for component in component_container.get_children():
		if (component is IComponent):
			component._initialize(self, load_data_for_components.get(component.component_name, {}))
			list_base_components[component.component_name] = component

	if need_disconnect:
		SSignalBus.entity_initialize_started.disconnect(_initialize)

	## 4. 在组件容器完成初始化后，进行组件内元素的延迟初始化
	_late_initialize()

	## 5. 发射初始化完成信号，标志着本实体的初始化完成
	initialize_complete.emit()


func _late_initialize():
	for component in list_base_components.values():
		component._late_initialize()
	for component in list_interface_components.values():
		component._late_initialize()


func _update(_delta: float):
	if SGameState.state_machine.get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._update(_delta)
		for interface_component in list_interface_components.values():
			interface_component._update(_delta)

func _fixed_update(_delta: float):
	if SGameState.state_machine.get_leaf_state() is GamingStateNormal:
		for base_component in list_base_components.values():
			base_component._fixed_update(_delta)
		for interface_component in list_interface_components.values():
			interface_component._fixed_update(_delta)

#region 存档系统
func _save_as(_data: SavedDataFile) -> Dictionary:
	return {}
	
func _load_by(_data: SavedDataFile) -> Dictionary:
	return {}
#endregion
