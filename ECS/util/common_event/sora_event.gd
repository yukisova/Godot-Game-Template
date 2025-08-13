## @editing: Sora
## @describe: 游戏事件工具类 - 提供常用的静态方法和事件处理
## 
## 该类封装了游戏中常用的事件处理方法，主要包括：
## - 对话系统的便捷调用
## - 通用事件触发器
## - 场景切换工具
## - 其他常用的静态工具方法
## 
## 设计目标：
## - 简化复杂系统的调用流程
## - 提供统一的事件处理接口
## - 减少代码重复和耦合
class_name SoraEvent
extends Node

## 对话气泡UI场景
## 用于显示对话内容的UI预制体
const DIALOGUE_BALLOON: PackedScene = preload("res://ui/ui/ui_dialogue/ui_dialogue.tscn")

## 启动对话系统（封装版）
## 对DialogueManager的封装，提供更简洁的对话启动接口
## @param dialogue: 对话资源文件
## @param _label: 对话标签，用于指定对话起始点（可选）
## @param _context: 对话上下文数据，用于传递变量到对话中（可选）
static func sora_dialogue_start(dialogue: DialogueResource, _label: String = "", _context: Array = []):
	var balloon = DIALOGUE_BALLOON.instantiate()
	DialogueManager._start_balloon(balloon, dialogue, _label, _context)
