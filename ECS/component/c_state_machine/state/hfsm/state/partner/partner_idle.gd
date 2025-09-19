## 伙伴空闲状态 - 伙伴AI的待机和隐藏状态
##
## 该状态表示伙伴在接收到指令后的空闲状态，伙伴会在指定区域进行隐藏并停止移动。
## 通常用于玩家需要独自行动或伙伴需要暂时脱离的情况。
##
## 核心功能：
## - 伙伴的静止待机
## - 隐藏状态的维持
## - 移动系统的暂停
## - 指令等待的准备状态
##
## 状态特征：
## - 停止所有主动移动
## - 保持在指定位置
## - 等待新的行动指令
## - 维持基础的响应能力
##
## 应用场景：
## - 玩家独自潜行时
## - 伙伴需要等待时
## - 特定剧情需要时
## - 战术部署的准备阶段
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 与伙伴状态机系统集成
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