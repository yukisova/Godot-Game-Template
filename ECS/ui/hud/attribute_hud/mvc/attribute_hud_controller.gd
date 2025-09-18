## 玩家属性HUD控制器 - MVC架构中的Controller层
## 协调Model和View之间的交互，处理业务逻辑和数据流
## 实现IHud接口以保持与现有系统的兼容性
## 管理组件的生命周期和错误处理
## [br][b]编辑者:[/b] Sora
class_name AttributeHudController
extends IHud

# MVC组件引用
var _model: RefCounted  # PlayerAttributeModel
var _view: CanvasLayer  # AttributeHudView

# 配置参数
@export var player_index: int = 0
@export var auto_initialize: bool = true

# 组件状态
var _is_initialized: bool = false
var _initialization_failed: bool = false

## 当游戏状态或绑定实体数据发生变化时调用
func _refresh() -> void:
	if !_is_initialized:
		if _initialization_failed:
			push_warning("AttributeHudController: 初始化失败，跳过刷新")
			return
		
		# 尝试重新初始化
		if not _initialize():
			push_error("AttributeHudController: 重新初始化失败")
			return
	
	# 刷新视图显示当前数据
	_refresh_view_display()

## 设置HUD的初始状态和数据绑定
func _initialize() -> bool:
	if _is_initialized:
		push_warning("AttributeHudController: 已经初始化，跳过重复初始化")
		return true
	
	# 创建并初始化Model
	if not _initialize_model():
		_initialization_failed = true
		return false
		
	# 初始化View
	if not _initialize_view():
		_cleanup_model()
		_initialization_failed = true
		return false
		
	# 绑定Model和View的交互
	_bind_model_view()
	
	# 初始化视图显示
	_initialize_view_display()
	
	_is_initialized = true
	_initialization_failed = false
	
	print("AttributeHudController: MVC架构初始化完成")
	return true

## Node生命周期 - 节点准备完成
func _ready() -> void:
	if auto_initialize:
		if not _initialize():
			push_error("AttributeHudController: 自动初始化失败")

## Node生命周期 - 节点退出场景树
func _exit_tree() -> void:
	_cleanup()

## 创建并初始化数据模型
func _initialize_model() -> bool:
	# 动态加载PlayerAttributeModel类
	var PlayerAttributeModel = load("res://ui/hud/attribute_hud/mvc/player_attribute_model.gd")
	_model = PlayerAttributeModel.new()
	
	if not _model.initialize(player_index):
		push_error("AttributeHudController: PlayerAttributeModel初始化失败")
		_model = null
		return false
		
	print("AttributeHudController: Model初始化成功")
	return true

## 初始化视图组件
func _initialize_view() -> bool:
	# 查找视图组件（假设它是当前节点的子节点）
	_view = get_node("AttributeHudView") as CanvasLayer
	
	if !_view:
		push_error("AttributeHudController: 未找到AttributeHudView子节点")
		return false
	
	# 验证子节点确实是AttributeHudView类型
	if !_view.has_method("update_health"):
		push_error("AttributeHudController: 子节点不是有效的AttributeHudView")
		return false
	
	print("AttributeHudController: View初始化成功")
	return true

## 绑定Model变化到View更新
func _bind_model_view() -> void:
	if !_model or !_view:
		push_error("AttributeHudController: Model或View未初始化，无法绑定")
		return
	
	# 绑定数据变化信号到视图更新方法
	_model.health_changed.connect(_view.update_health)
	_model.fitness_changed.connect(_view.update_fitness)  
	_model.weapon_changed.connect(_view.update_weapon)
	_model.equipment_changed.connect(_view.update_equipment)
	
	# 绑定视图交互信号到控制器处理（如果需要的话）
	# _view.health_bar_clicked.connect(_on_health_bar_clicked)
	# _view.fitness_bar_clicked.connect(_on_fitness_bar_clicked)
	
	print("AttributeHudController: Model-View绑定完成")

## 初始化视图显示状态
func _initialize_view_display() -> void:
	if !_model or !_view:
		return
		
	# 使用Model的当前数据初始化View显示
	_view.initialize_display(
		_model.health_value, _model.health_max_value,
		_model.fitness_value, _model.fitness_max_value,
		_model.weapon_texture, _model.equipment_texture
	)
	
	print("AttributeHudController: View初始显示完成")

## 刷新视图显示（强制更新所有数据）
func _refresh_view_display() -> void:
	if !_model or !_view:
		return
		
	# 手动触发所有数据的更新
	_view.update_health(_model.health_value, _model.health_max_value)
	_view.update_fitness(_model.fitness_value, _model.fitness_max_value)
	_view.update_weapon(_model.weapon_texture)
	_view.update_equipment(_model.equipment_texture)

## 清理所有资源和连接
func _cleanup() -> void:
	_cleanup_model_view_bindings()
	_cleanup_model()
	_cleanup_view()
	
	_is_initialized = false
	_initialization_failed = false

## 清理Model和View之间的绑定
func _cleanup_model_view_bindings() -> void:
	if !_model or !_view:
		return
		
	# 断开信号连接
	if _model.health_changed.is_connected(_view.update_health):
		_model.health_changed.disconnect(_view.update_health)
	if _model.fitness_changed.is_connected(_view.update_fitness):
		_model.fitness_changed.disconnect(_view.update_fitness)
	if _model.weapon_changed.is_connected(_view.update_weapon):
		_model.weapon_changed.disconnect(_view.update_weapon)
	if _model.equipment_changed.is_connected(_view.update_equipment):
		_model.equipment_changed.disconnect(_view.update_equipment)

## 清理数据模型
func _cleanup_model() -> void:
	if _model:
		_model.cleanup()
		_model = null

## 清理视图
func _cleanup_view() -> void:
	if _view:
		_view.stop_all_animations()
		_view = null

# 公共API方法

## 显示HUD
func show_hud() -> void:
	if _view:
		_view.show_view()

## 隐藏HUD  
func hide_hud() -> void:
	if _view:
		_view.hide_view()

## 设置HUD透明度
func set_hud_alpha(alpha: float) -> void:
	if _view:
		_view.set_view_alpha(alpha)

## 强制刷新数据（外部调用接口）
func force_refresh() -> void:
	_refresh()

## 重新初始化（故障恢复）
func reinitialize() -> bool:
	_cleanup()
	return _initialize()

# 调试和状态查询方法

## 检查控制器是否正常工作
func is_working() -> bool:
	return _is_initialized and !_initialization_failed and _model != null and _view != null

## 获取详细状态信息
func get_debug_info() -> Dictionary:
	var info = {
		"controller_initialized": _is_initialized,
		"initialization_failed": _initialization_failed,
		"model_exists": _model != null,
		"view_exists": _view != null,
		"player_index": player_index
	}
	
	if _model:
		info["model_info"] = _model.get_debug_info()
	
	if _view:  
		info["view_info"] = _view.get_debug_info()
		
	return info

## 打印调试信息
func print_debug_info() -> void:
	print("=== AttributeHudController 调试信息 ===")
	var info = get_debug_info()
	for key in info.keys():
		print("%s: %s" % [key, str(info[key])])
	print("=====================================")

# 预留的用户交互处理方法

## 血量条点击处理（预留）
func _on_health_bar_clicked() -> void:
	print("AttributeHudController: 血量条被点击")
	# 这里可以添加具体的交互逻辑，比如显示详细信息面板

## 体力条点击处理（预留）  
func _on_fitness_bar_clicked() -> void:
	print("AttributeHudController: 体力条被点击")
	# 这里可以添加具体的交互逻辑，比如显示体力消耗详情
