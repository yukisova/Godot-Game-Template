## @editing: Sora [br]
## @describe: 对话交互 - 实现与NPC或其他实体的对话功能
## 
## 该交互实现了完整的对话系统，当玩家与支持对话的实体交互时，
## 会启动对话界面并进入对话状态。对话期间玩家将被"硬控制"，
## 游戏状态机会切换到过场剧情状态以确保对话不被打断。
## 
## 对话系统特性：
## - DialogueManager集成：使用项目的对话管理器系统
## - 状态控制：自动切换游戏状态确保对话流畅进行
## - 上下文传递：支持向对话传递上下文信息和参数
## - UI管理：自动生成和管理对话界面
## - 节点路径解析：自动解析配置中的节点路径引用
## 
## 工作流程：
## 1. 玩家触发对话交互
## 2. 生成对话UI界面
## 3. 启动DialogueManager处理对话逻辑
## 4. 传递上下文信息和目标实体数据
## 5. 游戏进入对话状态，限制玩家操作
## 
## 应用场景：
## - NPC对话：与游戏角色进行情节对话
## - 剧情推进：通过对话推进游戏剧情
## - 信息获取：从NPC获取任务或提示信息
## - 商店交易：通过对话界面进行交易
## - 教程指导：新手教程和游戏指导
class_name InteractionDialogue
extends Interaction

## 对话UI场景
## 用于显示对话内容的UI界面场景
@export var test_dialogue_ui: PackedScene

## 对话资源
## 包含对话内容、选项和逻辑的对话资源文件
@export var test_dialogue: DialogueResource

## 对话标签
## 对话资源中的起始标签或节点名称
@export var test_dialogue_label: StringName

## 对话上下文信息
## 传递给对话系统的额外数据和配置信息
@export var dialogue_info: Dictionary[String, Variant]

## 交互激活处理
## 当对话交互被触发时启动对话系统
## @param _target_entity: 触发交互的目标实体（通常是玩家）
func _on_interact_activated(_target_entity: FixedEntity):
	# 生成对话UI界面
	var dialogue_ui = SUiSpawner._spawn_ui(test_dialogue_ui)
	
	# 准备对话上下文数据
	var context_data = [
		SoraEvent.fixed_dictionary(self, dialogue_info),           # 修正后的对话配置信息
		{"target_entity": _target_entity} # 触发对话的实体信息
	]
	
	# 启动对话气泡，开始对话流程
	DialogueManager._start_balloon(dialogue_ui, test_dialogue, test_dialogue_label, context_data)
	
	print("对话交互: 开始对话 -> ", test_dialogue_label)

## 交互取消激活处理
## 当对话交互被取消时的清理工作
func _on_interact_deactivated():
	# 对话系统会自动处理对话结束，这里通常不需要特殊处理
	print("对话交互: 交互取消激活")
