## 游戏开始过场UI - 游戏启动时的剧情介绍和角色设置界面
##
## 该UI负责游戏开始时的完整过场流程，提供沉浸式的游戏开场体验。
## 集成了动画、对话和状态管理系统，确保流畅的游戏启动流程。
##
## 核心功能：
## - 播放开场动画和提示信息
## - 展示剧情背景和角色介绍
## - 处理游戏难度和角色选择
## - 确定后续的剧情分支路线
## - 无缝过渡到主游戏流程
##
## 主要特性：
## - 自动播放开场动画序列
## - 集成对话系统进行剧情展示
## - 处理玩家的初始设置选择
## - 协调各系统的状态切换
##
## 使用场景：
## - 新游戏的开场剧情
## - 角色背景故事介绍
## - 游戏设置的初始配置
## - 教程引导的起始点
##
## 技术特性：
## - 动画与对话的协调播放
## - 状态机集成的流程控制
## - 模块化的资源加载机制
## - 错误处理和状态验证
##
## 架构设计：
## - 继承自 [IUi] 基类
## - 集成 [AnimationPlayer] 的动画控制
## - 基于 [DialogueManager] 的对话系统
## - 与 [SGameState] 和 [SMapData] 的状态管理集成
## - 支持 [PackedScene] 的场景切换
##
## [br][b]编辑者:[/b] Sora
extends IUi

#region 场景配置

## 开始游戏场景
## 
## 过场完成后要加载的主游戏场景，类型为 [PackedScene]。
@export var start_game_scene: PackedScene

#endregion

#region 场景组件引用

## 动画播放器
## 
## 控制开场动画的播放，类型为 [AnimationPlayer]。
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer

#endregion

#region 对话资源配置

## 对话面板预制体
## 
## 用于显示剧情对话的UI组件预制体。
const dialog_panel_pack = preload("res://ui/ui_composite/canvas/dialogue_panel/dialog_panel.tscn")

## 对话资源文件
## 
## 包含开场剧情对话内容的 [DialogueResource] 资源。
const dialog_resource = preload("res://resource/plugins_resource/dialogue/ui_cutscene.dialogue")

## 对话标签
## 
## 指定要播放的对话起始点标识符。
const dialog_label = "ui_进入游戏"

#endregion

#region 过场流程控制

## UI准备就绪（重写方法）
## 
## 启动完整的开场过场流程。
func _ready() -> void:
	print("开场过场UI: 开始播放开场流程")
	
	# 播放开场提示动画
	animation_player.play("tip")
	await animation_player.animation_finished
	print("开场过场UI: 开场动画播放完成")
	
	# 创建并启动对话系统
	var dialog_panel = dialog_panel_pack.instantiate()
	add_child(dialog_panel)
	DialogueManager._start_balloon(dialog_panel, dialog_resource, dialog_label, [])
	print("开场过场UI: 对话系统已启动")
	
	# 等待对话结束
	await DialogueManager.dialogue_ended
	print("开场过场UI: 对话流程完成")
	
	# 验证并切换游戏状态
	_transition_to_game()

## 过渡到主游戏
## 
## 验证状态机并启动主游戏流程。
func _transition_to_game():
	var game_state_machine = SGameState.state_machine as StateMachineHfsm 
	var current_state = game_state_machine._get_active_state()
	
	if current_state is GameStartState:
		print("开场过场UI: 状态机验证通过，开始游戏")
		current_state.update_trigger = true
		SMapData.map_registered.emit(start_game_scene)
		SAudioMaster.play_music(null)
		unspawn()
	else:
		push_error("开场过场UI: 状态机错误，当前状态: %s" % [current_state.name])

#endregion
