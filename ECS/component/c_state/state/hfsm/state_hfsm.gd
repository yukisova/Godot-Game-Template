## @editing: Sora [br]
## @describe: HFSM状态基类 - 混合层次化和下推自动机的复合状态实现
## 
## 该抽象类是HFSM（层次化有限状态机）中的状态基类，同时集成了PDA（下推自动机）
## 的功能，实现了既支持层次化状态管理又支持状态栈管理的复合状态系统。
## 
## 核心特性：
## - HFSM状态过渡：支持同级状态间的切换和层次化状态管理
## - PDA状态栈：支持状态的压入、弹出和回滚操作
## - 状态归属：每个状态都归属于特定的状态机
## - 上下文管理：状态间的数据传递和共享机制
## - 模糊更新：非激活状态的后台更新能力
## 
## 混合架构优势：
## - 层次管理：通过HFSM实现复杂行为的分层组织
## - 状态记忆：通过PDA实现状态历史的保存和恢复
## - 灵活切换：支持平级切换和压栈式状态管理
## - 上下文保持：状态切换时保持必要的上下文信息
## 
## 应用场景：
## - AI行为：敌人的复杂行为状态管理
## - 游戏流程：多步骤的游戏流程控制
## - 对话系统：支持中断和恢复的对话状态
## - 战斗系统：技能释放和状态效果管理
@tool
@abstract class_name StateHfsm
extends IState

## PDA状态弹出信号
## 当需要从状态栈中弹出状态时发出
signal state_poped

## PDA状态压入或回滚信号
## 当需要压入新状态或回滚到历史状态时发出
## @param to_state: 目标PDA状态
signal state_pushed(to_state: StatePda)

## HFSM状态过渡信号
## 当需要进行同级状态切换时发出
## @param to_state: 目标状态
@warning_ignore("unused_signal")
signal state_transition(to_state)

## 状态归属的状态机
## 指向管理此状态的HFSM状态机实例
var belong_state_machine: StateMachineHfsm

## HFSM状态过渡配置
## 定义当前状态可以过渡到的目标状态列表，键为过渡条件，值为过渡记录
@export var hfsm_state_transition: Dictionary[StringName, TrainsitionRecord]

## 可压入的PDA状态列表
## 定义当前状态可以压入状态栈的PDA状态数组
@export var possible_pda_state_push: Array[StatePda]

## PDA状态快速查找字典
## 基于关键词快速查找PDA状态的映射表
var confirm_pda_state_dict: Dictionary[String, StatePda]

## PDA状态栈
## 存储当前状态的状态栈，栈顶状态（最后一个）为当前执行的状态
## 初始状态包含自身作为栈底
var pda_state_stack: Array[IState] = [self]

## 状态设置
## 初始化信号连接和PDA状态字典
func _setup():
	state_poped.connect(_on_state_poped)
	state_pushed.connect(_on_state_pushed_rolled)
	
	# 构建PDA状态的快速查找字典
	for pda_state in possible_pda_state_push:
		confirm_pda_state_dict[pda_state.keyword] = pda_state

## PDA状态压入或回滚处理
## 处理状态的压入操作或回滚到历史状态
## @param to_state: 目标PDA状态，为null时执行回滚操作
func _on_state_pushed_rolled(to_state: StatePda = null):
	var roll_index: int = 0
	
	if to_state:
		# 查找目标状态在栈中的位置
		roll_index = pda_state_stack.find(to_state)
	
	if roll_index == -1:
		# 新状态压入栈
		if pda_state_stack.size() > 1:
			pda_state_stack[-1].pop_trigger = false
		
		# 退出当前栈顶状态
		pda_state_stack[-1]._exit()
		
		# 压入新状态
		pda_state_stack.push_back(to_state)
		pda_state_stack[-1]._enter()
		pda_state_stack[-1].belong_state = self
		
	elif roll_index == pda_state_stack.size() - 1:
		# 目标状态已经是栈顶，无需操作
		return
	else:
		# 回滚到历史状态
		pda_state_stack[-1].pop_trigger = false
		pda_state_stack[-1]._exit()
		pda_state_stack.pop_back()
		
		# 弹出栈中位于目标状态之上的所有状态
		while pda_state_stack.size() - 1 > roll_index:
			pda_state_stack.pop_back()
		
		# 重新进入目标状态
		pda_state_stack[-1]._enter()

## PDA状态弹出处理
## 从状态栈中弹出当前栈顶状态，恢复到上一个状态
func _on_state_poped():
	if pda_state_stack[-1] != self:
		# 清理栈顶状态
		pda_state_stack[-1].belong_state = null
		pda_state_stack[-1].pop_trigger = false
		pda_state_stack[-1]._exit()
		pda_state_stack.pop_back()
		
		# 恢复新的栈顶状态
		pda_state_stack[-1]._enter()
	else:
		push_error("HFSM状态: 试图弹出栈底状态，这是不允许的操作")

## 清空状态栈并退出
## 清理所有PDA状态并准备状态切换
func _clear_stack_and_exit():
	var exit_flag = pda_state_stack.size() > 1
	
	# 退出当前栈顶状态
	pda_state_stack[-1]._exit()

	# 清空栈中的所有PDA状态
	while pda_state_stack.size() > 1:
		pda_state_stack.pop_back()
	
	# 如果有PDA状态被清理，则退出栈底状态
	if exit_flag:
		pda_state_stack[-1]._exit()

## 固定更新（内部方法）
## 将物理帧更新传递给当前栈顶状态
## @param _delta: 物理帧时间间隔
func _f_u(_delta: float) -> void:
	pda_state_stack[-1]._fixed_update(_delta)

## 主更新（内部方法）
## 执行状态栈的更新逻辑，包括PDA状态的自动弹出和模糊更新
## @param _delta: 帧时间间隔
func _u(_delta: float) -> void:
	var top_state = pda_state_stack[-1]
	
	# 更新栈顶状态
	top_state._update(_delta)
	
	# 检查PDA状态的弹出触发器
	if top_state is StatePda:
		if top_state.pop_trigger:
			state_poped.emit()
	
	# 执行栈中其他状态的模糊更新
	for state: IState in pda_state_stack:
		# 跳过栈顶状态（已经执行过主更新）和非自身的栈顶状态
		if state == pda_state_stack[-1] and state != self:
			continue
		state._blur_update(_delta)

## 暂停（内部方法）
## 暂停栈顶状态并等待游戏继续
func _p():
	var top_state = pda_state_stack[-1]
	top_state._pause()
	await SGameState.game_continue
	top_state._continue()

## 获取过渡目标状态
## 根据关键词查找可过渡的目标状态
## @param keyword: 过渡条件关键词
## @return: 目标状态节点
func get_transition_state(keyword: StringName = ""):
	if hfsm_state_transition.has(keyword):
		return get_node(hfsm_state_transition[keyword].to_state)
	else:
		push_error("HFSM状态: 未找到过渡状态关键词 -> " + str(keyword))
		return null

## 属性验证
## 在编辑器中根据状态机类型动态调整可见属性
func _validate_property(property: Dictionary) -> void:
	if property.name == "hfsm_state_transition":
		# 根状态机不需要过渡状态列表
		if self is StateMachineHfsm and self.get_parent() is not StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "possible_pda_state_push":
		# 状态机本身不需要PDA状态推入列表
		if self is StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR

## 获取根状态机
## 递归向上查找并返回根状态机实例
## @return: 根状态机实例
func _get_root_statemachine():
	var current = self
	while current is StateHfsm:
		if current is StateMachineHfsm:
			if current.is_root:
				return current
		else:
			current = current.get_parent()
	push_error("HFSM状态: 未找到标记为根的状态机，请确保根状态机的is_root为true")
