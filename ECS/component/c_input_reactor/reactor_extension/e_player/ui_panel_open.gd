## UI面板开启扩展 - 处理玩家UI界面的打开操作
## 监听按键输入打开对应UI界面，支持游戏内和游戏外UI
## 包括思维界面（装备背包）和暂停界面（设置退出）
## [br][b]编辑者:[/b] Sora
class_name UIPanelOpenExtension
extends ReactorExtension

## 思维界面场景
## 包含装备、背包等游戏内界面
@export var brain_ui: PackedScene

## 状态组件引用
## 为思维界面提供角色状态数据
@export var c_status: CStatusList

## 暂停界面场景
## 包含游戏设置、退出游戏等界面
@export var pause_ui: PackedScene

func _late_initialize():
	if c_input_reactor.component_owner in SMainController.player_static.values():
		disabled = false
	else:
		disabled = true

## 检测思维界面和暂停界面的触发按键
func _listen():
	# 监听思维界面触发键（默认为Tab键）
	if c_input_reactor.validate_control("brain_trigger", SoraConstant.InputType.JUST_PRESSED, true):
		# 传递背包数据作为上下文信息
		SUiSpawner._spawn_ui(brain_ui, {"status": c_status})
	
	# 监听暂停界面触发键（默认为P键）
	elif c_input_reactor.validate_control("pause_game", SoraConstant.InputType.JUST_PRESSED, true):
		SUiSpawner._spawn_ui(pause_ui)
