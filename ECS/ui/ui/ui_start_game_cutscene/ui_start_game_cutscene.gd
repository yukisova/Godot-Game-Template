## [br][b]编辑者:[/b] Sora
extends UIController

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
const dialog_panel_pack = preload("res://ui/ui_c/canvas/dialogue_panel/dialog_panel.tscn")

## 对话资源文件
## 
## 包含开场剧情对话内容的 [DialogueResource] 资源。
const dialog_resource = preload("res://resource/plugins_resource/dialogue/测试对话.dialogue")

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
	var game_state_machine = SGameState.state_machine as StateMachine 
	var current_state = game_state_machine.get_active_state()
	
	if current_state is GameStartState:
		print("开场过场UI: 状态机验证通过，开始游戏")
		current_state.update_trigger = true
		SMapData.map_registered.emit(start_game_scene)
		SAudioMaster.play_music(null)
		unspawn()
	else:
		push_error("开场过场UI: 状态机错误，当前状态: %s" % [current_state.name])


#endregion
