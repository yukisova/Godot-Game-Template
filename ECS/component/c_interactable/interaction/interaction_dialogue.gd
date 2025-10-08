## 对话交互 - 实现与NPC或其他实体的对话功能
## 该交互实现了完整的对话系统，当玩家与支持对话的实体交互时，会启动对话界面并进入对话状态
## 核心功能：DialogueManager集成、状态控制、上下文传递、UI管理、节点路径解析
## 对话系统特性：动态UI生成和销毁、丰富的上下文数据传递、实体信息的自动注入
## 工作流程：玩家触发对话→生成对话UI界面→启动DialogueManager→传递上下文信息→游戏进入对话状态
## 应用场景：NPC对话、剧情推进、信息获取、商店交易、教程指导
## 架构设计：继承自Interaction基类，集成PackedScene的UI管理，基于DialogueResource的对话内容
## [br][b]编辑者:[/b] Sora
class_name InteractionDialogue
extends IInteraction

## 对话UI场景
## 用于显示对话内容的UI界面场景
const PATH_DIALOGUE_FLOAT: String = "res://ui/ui/ui_dialogue/float/ui_dialogue_float.tscn"
const PATH_DIALOGUE_NORMAL: String = "res://ui/ui/ui_dialogue/normal/ui_dialogue_normal.tscn"

## 对话资源
## 包含对话内容、选项和逻辑的对话资源文件
@export var test_dialogue: DialogueResource

## 对话标签
## 对话资源中的起始标签或节点名称
@export var test_dialogue_label: StringName

## 对话上下文信息
## 传递给对话系统的额外数据和配置信息
@export var dialogue_info: Dictionary[String, Variant]

var is_caption: bool = true

## 交互激活处理—当对话交互被触发时启动对话系统
## [param _target_entity]: 触发交互的目标实体（通常是玩家）
func __interact_begin(_target_entity: IEntity) -> bool:
	# 生成对话UI界面
	
	# 准备对话上下文数据
	var context_data = [
		SoraEvent.fixed_dictionary(self, dialogue_info),           # 修正后的对话配置信息
		{"target_entity": _target_entity} # 触发对话的实体信息
	]
	
	if is_caption:
		var caption_hud: UIHudController = SUiSpawner._get_hud("caption")
		caption_hud.show()
		caption_hud.caption_changed.emit(test_dialogue)
	else:
		var float_dialogue: PackedScene = load(PATH_DIALOGUE_NORMAL)
		var dialogue_ui = await SUiSpawner._spawn_ui(float_dialogue)
	# 启动对话气泡，开始对话流程
		DialogueManager._start_balloon(dialogue_ui, test_dialogue, test_dialogue_label, context_data)
	
	print("对话交互: 开始对话 -> ", test_dialogue_label)
	return true

func __interact_reset() -> void:
	print("对话交互: 结束对话 -> ", test_dialogue_label)
