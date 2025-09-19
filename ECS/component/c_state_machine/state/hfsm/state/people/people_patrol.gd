## 人物巡逻状态 - NPC的巡逻移动状态
##
## 该状态实现了普通NPC的巡逻行为，使角色在指定区域内进行有规律的移动。
## 常用于守卫、巡逻兵等需要定期移动的NPC角色。
##
## 核心功能：
## - 路径规划的巡逻移动
## - 巡逻点之间的自动切换
## - 巡逻路线的循环执行
## - 与其他状态的流畅转换
##
## 巡逻特性：
## - 预定义巡逻路径的执行
## - 巡逻点的顺序或随机访问
## - 巡逻速度的灵活控制
## - 巡逻暂停和恢复机制
##
## 应用场景：
## - 守卫的定期巡逻
## - 士兵的警戒巡逻
## - 商人的区域移动
## - 清洁工的工作路线
## - 背景角色的动态展示
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 支持导航系统的集成
## - 为巡逻逻辑扩展预留接口
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