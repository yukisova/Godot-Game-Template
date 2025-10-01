## 实体数据注入规则
## 与entity_data_template配合使用，用于指定在何时，何处，何情况下对哪些实体注入代表哪些意味的数据
## 可以实现对指定的敌人，指定的对象统一初始化信息，可自定义筛选条件
## [br][b]编辑者:[/b] Sora
class_name EntityInjectRule
extends Resource
enum InjectionFliter {
	BY_COMPONENT,    # 根据组件类型
	BY_POSITION,     # 根据位置范围
	BY_NAME,         # 根据名称模式
	BY_CUSTOM_FILTER # 自定义筛选器
}

## 规则的名称
@export var rule_name: String
## 对应的entity_data_template的名称
@export var template_name: String
# 注入过滤器
@export var injection_fliter: InjectionFliter
@export var injection_timing: LCEntityDataInjecter.InjectionTiming = LCEntityDataInjecter.InjectionTiming.AUTO

# 组件筛选相关
@export var component_types: Array[IComponent.ComponentName]
@export var require_all_components: bool = false

# 位置筛选相关
@export var position_center: Vector2
@export var position_radius: float = 100.0

# 名称筛选相关
@export var name_pattern: String
@export var use_regex: bool = false

# 自定义筛选器
@export var custom_filter: Callable

