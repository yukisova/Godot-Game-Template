## @editing: Sora [br]
## @describe: UI面板开启扩展 - 处理玩家UI界面的打开操作
## 
## 该扩展负责监听特定的按键输入并打开对应的UI界面。
## 分为游戏内UI（装备、背包等）和游戏外UI（设置、暂停等）两类。
## 
## 支持的UI类型：
## - 思维界面（Brain UI）：装备、背包、角色信息等游戏内界面
## - 暂停界面（Pause UI）：设置、退出游戏等游戏外界面
## 
## 功能特性：
## - 按键触发UI显示
## - UI生成器系统集成
## - 上下文数据传递
## - 扩展数据绑定
class_name UIPanelOpenExtension
extends ReactorExtension

## 思维界面场景
## 包含装备、背包等游戏内信息相关的设置菜单
@export var brain_ui: PackedScene

## 背包扩展组件
## 为思维界面提供背包数据支持
@export var c_status: CStatus

## 暂停界面场景
## 包含游戏设置、退出游戏等游戏外相关的设置菜单
@export var pause_ui: PackedScene

## 监听UI触发输入
## 检测思维界面和暂停界面的触发按键
func _listen():
	# 监听思维界面触发键（默认为Tab键）
	if c_input_reactor.validate_control("brain_trigger", c_input_reactor.ControlMode.just_pressed):
		# 传递背包数据作为上下文信息
		SUiSpawner._spawn_ui(brain_ui, {"status": c_status})
	
	# 监听暂停界面触发键（默认为P键）
	elif c_input_reactor.validate_control("pause_game", c_input_reactor.ControlMode.just_pressed):
		SUiSpawner._spawn_ui(pause_ui)
