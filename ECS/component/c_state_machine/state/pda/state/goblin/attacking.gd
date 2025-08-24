## 哥布林攻击状态 - 哥布林执行攻击行为的PDA状态
##
## 该PDA状态处理哥布林的攻击逻辑，包括攻击动画播放、
## 伤害判定、攻击间隔控制等核心攻击行为。
##
## 状态特性：
## - 执行攻击动作
## - 播放攻击动画
## - 处理攻击伤害判定
## - 控制攻击节奏
##
## 触发条件：
## - 目标进入攻击范围
## - 从追击状态过渡而来
## - 满足攻击条件（距离、朝向等）
##
## 退出条件：
## - 攻击完成后目标仍在范围内 → 继续攻击或短暂等待
## - 目标脱离攻击范围 → 返回追击状态
## - 目标消失或死亡 → 返回巡逻状态
##
## 架构设计：
## - 继承自 [StatePda] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 可中断和恢复的PDA状态
## - 与攻击系统和动画系统集成
##
## [br][b]编辑者:[/b] Sora
@tool
extends StatePda

@export var sight_box: SightBox
@export var goblin_attack: ITriggerAction ## 哥布林的攻击模组，目前所设定的攻击形式很单一


func _enter_tree() -> void:
	keyword = "attacking"

func _enter():
	print("哥布林尝试攻击")
	
	#goblin_attack.action_triggered.emit()

func _update(_delta: float) -> void:
	pass

func _exit():
	pass
