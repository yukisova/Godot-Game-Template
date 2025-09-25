class_name EntityDataInjecter
extends Node

## 实体数据批量注入器
## 负责在地图加载时批量给指定实体注入初始化数据
## 支持多种筛选条件和注入时机

signal injection_completed(injected_count: int)
signal injection_failed(error_message: String)

@export_group("数据注入配置")
@export var data_templates: Array[EntityDataTemplate] = []
@export var injection_rules: Array[EntityInjectRule] = []

@export_group("调试设置")  
@export var enable_debug_logs: bool = false
@export var show_injection_summary: bool = true

var _level: Level
var _injected_entities: Array[FixedEntity] = []
var _injection_stats: Dictionary = {}

## 设置Level集成
func _initialize():
	_level = get_parent() as Level
	if not _level:
		_log_error("EntityDataInjecter 必须作为 Level 的子节点")
		return
	# 根据不同时机连接信号
	match _get_preferred_injection_timing():
		InjectionTiming.BEFORE_ENTITY_INITIALIZE:
			# 在实体初始化开始前注入
			_level.level_fully_loaded.connect(_on_level_loaded)
		InjectionTiming.AFTER_ENTITY_INITIALIZE:  
			# 在所有实体初始化完成后注入
			_level.level_entity_fully_initialize.connect(_on_entities_initialized)
		InjectionTiming.IMMEDIATE:
			# 立即执行
			execute_injection_rules.call_deferred()

#region 核心注入接口

## 批量注入数据到指定实体列表
func batch_inject_data(target_entities: Array[FixedEntity], data_template: Dictionary) -> int:
	var injected_count = 0
	
	for entity in target_entities:
		if _inject_data_to_entity(entity, data_template):
			injected_count += 1
			_injected_entities.append(entity)
	
	_log_debug("批量注入完成，成功注入 %d/%d 个实体" % [injected_count, target_entities.size()])
	return injected_count

## 根据筛选条件注入数据
func inject_by_filter(filter_func: Callable, data_template: Dictionary) -> int:
	var target_entities = _get_entities_by_filter(filter_func)
	return batch_inject_data(target_entities, data_template)

## 根据组件类型注入数据
func inject_by_component_type(component_types: Array[IComponent.ComponentName], data_template: Dictionary, require_all: bool = false) -> int:
	var filter_func = func(entity: FixedEntity) -> bool:
		if require_all:
			return _entity_has_all_components(entity, component_types)
		else:
			return _entity_has_any_component(entity, component_types)
	
	return inject_by_filter(filter_func, data_template)

## 根据位置范围注入数据
func inject_by_position_range(center: Vector2, radius: float, data_template: Dictionary) -> int:
	var filter_func = func(entity: FixedEntity) -> bool:
		return entity.global_position.distance_to(center) <= radius
	
	return inject_by_filter(filter_func, data_template)

## 根据实体名称模式注入数据
func inject_by_name_pattern(name_pattern: String, data_template: Dictionary, use_regex: bool = false) -> int:
	var filter_func = func(entity: FixedEntity) -> bool:
		if use_regex:
			var regex = RegEx.new()
			regex.compile(name_pattern)
			return regex.search(entity.name) != null
		else:
			return entity.name.contains(name_pattern)
	
	return inject_by_filter(filter_func, data_template)

#endregion

#region 数据模板和规则系统

## 执行所有配置的注入规则
func execute_injection_rules() -> Dictionary:
	var results = {}
	_injection_stats.clear()
	
	for rule in injection_rules:
			
		var template_data = _get_template_data(rule.template_name)
		if template_data.is_empty():
			_log_error("未找到数据模板: %s" % rule.template_name)
			continue
		
		var injected_count = 0
		match rule.injection_type:
			EntityInjectRule.InjectionFliter.BY_COMPONENT:
				injected_count = inject_by_component_type(rule.component_types, template_data, rule.require_all_components)
			EntityInjectRule.InjectionFliter.BY_POSITION:
				injected_count = inject_by_position_range(rule.position_center, rule.position_radius, template_data)
			EntityInjectRule.InjectionFliter.BY_NAME:
				injected_count = inject_by_name_pattern(rule.name_pattern, template_data, rule.use_regex)
			EntityInjectRule.InjectionFliter.BY_CUSTOM_FILTER:
				if rule.custom_filter.is_valid():
					injected_count = inject_by_filter(rule.custom_filter, template_data)
		
		results[rule.rule_name] = injected_count
		_injection_stats[rule.rule_name] = injected_count
	
	if show_injection_summary:
		_show_injection_summary(results)
	
	injection_completed.emit(_get_total_injected_count())
	return results

## 获取数据模板
func _get_template_data(template_name: String) -> Dictionary:
	for template in data_templates:
		if template.template_name == template_name:
			return template.get_template_data()
	return {}
#endregion

#region Level系统集成
func _on_level_loaded():
	_log_debug("地图加载完成，开始执行实体数据注入")
	execute_injection_rules()

func _on_entities_initialized():
	_log_debug("所有实体初始化完成，开始执行数据注入")
	execute_injection_rules()

func _get_preferred_injection_timing() -> InjectionTiming:
	# 根据注入规则类型智能选择时机
	for rule in injection_rules:
		if rule.injection_timing != InjectionTiming.AUTO:
			return rule.injection_timing
	
	# 默认在实体初始化完成后注入
	return InjectionTiming.AFTER_ENTITY_INITIALIZE

#endregion

#region 辅助方法

## 给单个实体注入数据
func _inject_data_to_entity(entity: FixedEntity, data_template: Dictionary) -> bool:
	if not entity or not entity.component_container:
		return false
	
	# 使用现有的数据绑定机制
	entity._init_data_binding(data_template)
	_log_debug("成功注入数据到实体: %s" % entity.name)
	return true

## 根据筛选条件获取实体列表
func _get_entities_by_filter(filter_func: Callable) -> Array[FixedEntity]:
	var result: Array[FixedEntity] = []
	if not _level:
		return result
	
	for child in _level.get_children():
		if child is FixedEntity and filter_func.call(child):
			result.append(child)
	
	return result

## 检查实体是否拥有所有指定组件
func _entity_has_all_components(entity: FixedEntity, component_types: Array[IComponent.ComponentName]) -> bool:
	for component_type in component_types:
		if not entity.get_other_component(component_type):
			return false
	return true

## 检查实体是否拥有任意指定组件
func _entity_has_any_component(entity: FixedEntity, component_types: Array[IComponent.ComponentName]) -> bool:
	for component_type in component_types:
		if entity.get_other_component(component_type):
			return true
	return false

## 获取总注入实体数量
func _get_total_injected_count() -> int:
	return _injected_entities.size()

## 显示注入摘要
func _show_injection_summary(results: Dictionary):
	print("=== 实体数据注入摘要 ===")
	var total = 0
	for rule_name in results.keys():
		var count = results[rule_name]
		total += count
		print("规则 '%s': 注入了 %d 个实体" % [rule_name, count])
	print("总计注入实体数量: %d" % total)
	print("========================")

## 调试日志
func _log_debug(message: String):
	if enable_debug_logs:
		print("[EntityDataInjecter] %s" % message)

func _log_error(message: String):
	print_rich("[color=red][EntityDataInjecter] 错误: %s[/color]" % message)
	injection_failed.emit(message)

#endregion
enum InjectionTiming {
	AUTO,                      # 自动选择时机
	IMMEDIATE,                 # 立即执行  
	BEFORE_ENTITY_INITIALIZE,  # 实体初始化前
	AFTER_ENTITY_INITIALIZE,   # 实体初始化后
}
