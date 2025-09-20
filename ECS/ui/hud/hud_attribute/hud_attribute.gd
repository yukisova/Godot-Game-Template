## 玩家属性HUD - 显示角色基础信息和快捷操作界面
## 该HUD集成了多个玩家相关的UI元素：时间循环系统的时钟显示、背包抽屉式快捷栏
## 物品拖拽和交互功能、玩家状态的实时更新
## 主要功能：实时显示游戏内时间、提供背包物品的快速访问、支持物品的拖拽操作
## UI特性：抽屉式背包展开/收起动画、可拖拽的物品图标、响应式布局适配
## 架构设计：继承自 [UIHudController] 基类，与 [FixedEntity] 的玩家实体绑定，集成 [InventoryExtension] 背包系统
## [br][b]编辑者:[/b] Sora
extends UIHudController

var binding_entitys: Array
var c_status_list: CStatusList

func _refresh():
	pass

func _initialize():
	var player_statics = SMainController.player_static.values()

	_bind_model_view()

	ui_view._initialize(
		{"player_static": player_statics}
	)
	ui_model._initialize(
		{"player_static": player_statics}
	)

# 绑定Model和View
func _bind_model_view():
	ui_model.health_changed.connect(ui_view._on_health_changed)
	ui_model.sound_changed.connect(ui_view._on_sound_changed)
	ui_model.fitness_changed.connect(ui_view._on_fitness_changed)
	ui_model.weapon_changed.connect(ui_view._on_weapon_changed)
	ui_model.equipment_changed.connect(ui_view._on_equipment_changed)
	ui_model.seek_state_changed.connect(ui_view._on_seek_state_changed)
