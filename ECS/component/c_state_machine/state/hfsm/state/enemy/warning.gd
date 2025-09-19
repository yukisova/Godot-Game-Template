## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 集成 [SightBox] 视线检测系统
## - 基于信号的状态响应机制
##
## [br][b]编辑者:[/b] Sora
@tool
extends StateHfsm

## 视线检测盒
## 
## 用于检测视野内目标的组件，类型为 [SightBox]。
@export var sight_box: SightBox

## 状态设置（重写方法）
## 
## 初始化警戒状态并连接视线检测信号。
func _setup():
	super()
	sight_box.target_losed.connect(_on_target_losed)
	sight_box.target_noticed.connect(_on_target_noticed)

## 目标丢失处理
## 
## 当视野内没有目标时触发目标丢失状态。
func _on_target_losed():
	if belong_state_machine.current_state == self:
		state_pushed.emit(confirm_pda_state_dict["target_lost"])

## 目标发现处理
## 
## 当视野内出现目标时触发目标锁定状态。
func _on_target_noticed():
	if belong_state_machine.current_state == self:
		state_pushed.emit(confirm_pda_state_dict["target_lock"])

func _blur_update(_delta: float) -> void:
	pass

func _pause() -> void:
	pass

func _continue() -> void:
	pass	

func _update(_delta: float) -> void:
	pass

func _fixed_update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _enter() -> void:
	pass