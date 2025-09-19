## 人物空闲状态 - NPC的基础待机状态
##
## 该状态表示普通NPC的空闲待机状态，是大部分非玩家角色的默认状态。
## 在此状态下，NPC保持静止或执行基础的待机动作。
##
## 核心功能：
## - 基础的待机行为
## - 状态转换的准备
## - 简单的待机逻辑
## - 与其他状态的衔接
##
## 状态特征：
## - 低功耗的状态维持
## - 等待外部触发的状态转换
## - 基础的动画播放
## - 环境感知的准备状态
##
## 应用场景：
## - NPC的默认状态
## - 对话前的待机状态
## - 任务NPC的等待状态
## - 背景角色的静态展示
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 为后续功能扩展预留接口
##
## [br][b]编辑者:[/b] Sora
@tool
extends StateHfsm

func _blur_update(_delta: float) -> void:
	pass

func _pause() -> void:
	pass

func _continue() -> void:
	pass	

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass    