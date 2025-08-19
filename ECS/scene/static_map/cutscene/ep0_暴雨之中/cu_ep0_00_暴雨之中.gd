## EP0暴雨之中过场剧情 - 游戏开场的过场动画序列
## 该过场剧情实现了游戏第一章"暴雨之中"的开场剧情序列，包含时间设置、对话系统集成和完整的过场流程控制
## 核心功能：时间循环系统的初始化、对话系统的启动和管理、过场状态的同步等待、节点路径的动态解析
## 剧情流程：设置时间循环读取时间为511→等待状态机转换完成→获取过渡HUD界面引用→生成对话UI界面→启动对话管理器播放剧情→等待对话结束完成过场
## 对话配置：对话场景预制的对话UI界面、对话资源EP0暴雨之中的对话内容、对话标签EP0地铁内开场的对话入口、对话信息可配置的对话上下文数据
## 技术特性：异步流程控制使用await进行流程同步、动态节点解析NodePath的运行时转换、资源预加载对话相关资源的预先加载、状态同步与游戏状态机的协调工作
## 架构设计：继承自ICutscene基类、集成DialogueManager对话系统、与SBlackboard时间循环系统集成、基于SGameState的状态管理
## [br][b]编辑者:[/b] Sora
extends ICutscene

## 对话UI场景
const dialogue_packed = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")

## 对话资源
const dialogue_resource = preload("res://resource/plugins_resource/dialogue/ep0_暴雨之中.dialogue")

## 对话标签字典
const dialogue_label: Dictionary = {\
	"part_1":"ep0_地铁内_开场"\
	}

## 对话信息配置
## 传递给对话系统的上下文数据
@export var dialogue_info: Dictionary[String, Variant]


## 开始过场剧情—执行EP0暴雨之中开场剧情的完整流程
func _start():
	# 设置时间循环系统的读取时间
	SBlackboard.sub_systems["time_loop"].read_time = 511
	
	# 等待状态机转换完全完成，确保过场可以正常进行
	await SGameState.state_machine.state_transition_finished
	
	# 获取过渡HUD界面的引用
	var transition = SUiSpawner.current_hud[&"transition"] as IHud

	# 生成对话UI界面并启动对话
	var dialogue = SUiSpawner._spawn_ui(dialogue_packed)
	DialogueManager._start_balloon(dialogue, dialogue_resource, dialogue_label["part_1"], [_fixed_dialogue_info()])
	
	# 等待对话完全结束
	await DialogueManager.dialogue_ended

## 修正对话信息—将NodePath类型的对话信息转换为实际的节点引用
func _fixed_dialogue_info() -> Dictionary:
	var dialogue_info_fixed = dialogue_info.duplicate_deep()
	for key in dialogue_info_fixed:
		if dialogue_info_fixed[key] is NodePath:
			dialogue_info_fixed[key] = get_node(dialogue_info_fixed[key])
	return dialogue_info_fixed
