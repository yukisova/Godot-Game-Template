extends IUi

#region 场景配置

## 开始游戏场景
## 
## 过场完成后要加载的主游戏场景，类型为 [PackedScene]。
@export var start_game_scene: PackedScene

#endregion

#region 场景组件引用

#endregion

#region 对话资源配置

## 对话面板预制体
## 
## 用于显示剧情对话的UI组件预制体。
const dialog_panel_pack = preload("res://ui/ui_composite/canvas/dialogue_panel/dialog_panel.tscn")

## 对话资源文件
## 
## 包含开场剧情对话内容的 [DialogueResource] 资源。
const dialog_resource = preload("res://resource/plugins_resource/dialogue/sight_light_索拉的世界.dialogue")

## 对话标签
## 
## 指定要播放的对话起始点标识符。
const dialog_label = "start"

#endregion

#region 过场流程控制

## UI准备就绪（重写方法）
## 
## 启动完整的开场过场流程。
func _ready() -> void:
	# 创建并启动对话系统
	var dialog_panel = dialog_panel_pack.instantiate()
	add_child(dialog_panel)
	DialogueManager._start_balloon(dialog_panel, dialog_resource, dialog_label, [])
	print("开场过场UI: 对话系统已启动")
	
	# 等待对话结束
	await DialogueManager.dialogue_ended
	print("开场过场UI: 对话流程完成")
	
	# 验证并切换游戏状态
	_transition_to_main_ui()


## 过渡到主菜单
## 
## 验证状态机并启动主菜单流程。
func _transition_to_main_ui():
	SUiSpawner._spawn_ui(SUiSpawner.main_menu_scene, {}, true)
#endregion
