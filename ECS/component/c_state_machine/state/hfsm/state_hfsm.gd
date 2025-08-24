## HFSM状态基类 - 混合层次化和下推自动机的复合状态实现
## 集成HFSM（层次化有限状态机）和PDA（下推自动机）功能
## 核心特性：状态过渡、状态栈、状态归属、上下文管理、模糊更新
## 应用场景：AI行为、游戏流程、对话系统、战斗系统
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name StateHfsm
extends IState

## PDA状态弹出信号，当需要从状态栈中弹出状态时发出
signal state_poped

## PDA状态压入或回滚信号，当需要压入新状态或回滚到历史状态时发出
## [param to_state]: 目标PDA状态，类型为 [StatePda]
signal state_pushed(to_state: StatePda)

## PDA状态完成之后，所进入的一个新状态，
signal state_plused(to_state: StatePda)

## HFSM状态过渡信号，当需要进行同级状态切换时发出
## [param to_state]: 目标状态
@warning_ignore("unused_signal")
signal state_transition(to_state)

## 状态归属的状态机，指向管理此状态的HFSM状态机实例
var belong_state_machine: StateMachineHfsm

## HFSM状态过渡配置，定义当前状态可以过渡到的目标状态列表
@export var hfsm_state_transition: Dictionary[StringName, TrainsitionRecord]

## 可压入的PDA状态列表，定义当前状态可以压入状态栈的PDA状态数组
@export var possible_pda_state_push: Array[StatePda]

## PDA状态快速查找字典，基于关键词快速查找PDA状态的映射表
var confirm_pda_state_dict: Dictionary[String, StatePda]

## PDA状态栈，存储当前状态的状态栈，栈顶状态为当前执行的状态
var pda_state_stack: Array[IState] = [self]

## 状态设置，初始化信号连接和PDA状态字典
func _setup():
	state_poped.connect(_on_state_poped)
	state_pushed.connect(_on_state_pushed_rolled)
	state_plused.connect(_on_state_plused)
	
	# 构建PDA状态的快速查找字典
	for pda_state in possible_pda_state_push:
		confirm_pda_state_dict[pda_state.keyword] = pda_state

## 与push不同，push的主要是由state_hfsm传入，plus的主要是由state_pda传入
func _on_state_plused(to_state: StatePda):
	state_pushed.emit(to_state)

## PDA状态压入或回滚处理，处理状态的压入操作或回滚到历史状态
## [param to_state]: 目标PDA状态，为null时执行回滚操作
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

## PDA状态弹出处理，从状态栈中弹出当前栈顶状态，恢复到上一个状态
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

## 清空状态栈并退出，清理所有PDA状态并准备状态切换
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

## 固定更新，将物理帧更新传递给当前栈顶状态
## [param _delta]: 物理帧时间间隔
func _f_u(_delta: float) -> void:
	pda_state_stack[-1]._fixed_update(_delta)

## 主更新，执行状态栈的更新逻辑，包括PDA状态的自动弹出和模糊更新
## [param _delta]: 帧时间间隔
func _u(_delta: float) -> void:
	var top_state = pda_state_stack[-1]
	
	# 更新栈顶状态
	top_state._update(_delta)
	
	# 检查PDA状态的弹出触发器
	if top_state is StatePda:
		if top_state.plus_trigger >= 0:
			state_plused.emit(top_state.plus_trigger_target[top_state.plus_trigger])
		elif top_state.pop_trigger:
			state_poped.emit()
	# 执行栈中其他状态的模糊更新
	for state: IState in pda_state_stack:
		# 跳过栈顶状态（已经执行过主更新）和非自身的栈顶状态
		if state == pda_state_stack[-1] and state != self:
			continue
		state._blur_update(_delta)

## 暂停，暂停栈顶状态并等待游戏继续
func _p():
	var top_state = pda_state_stack[-1]
	top_state._pause()
	await SGameState.game_continue
	top_state._continue()

## 获取过渡目标状态，根据关键词查找可过渡的目标状态
## [param keyword]: 过渡条件关键词，类型为 [StringName]
## [br][br][b]返回:[/b] 目标状态节点
func get_transition_state(keyword: StringName = ""):
	if hfsm_state_transition.has(keyword):
		return get_node(hfsm_state_transition[keyword].to_state)
	else:
		push_error("HFSM状态: 未找到过渡状态关键词 -> " + str(keyword))
		return null

## 属性验证，在编辑器中根据状态机类型动态调整可见属性
func _validate_property(property: Dictionary) -> void:
	if property.name == "hfsm_state_transition":
		# 根状态机不需要过渡状态列表
		if self is StateMachineHfsm and self.get_parent() is not StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "possible_pda_state_push":
		# 状态机本身不需要PDA状态推入列表
		if self is StateMachineHfsm:
			property.usage = PROPERTY_USAGE_NO_EDITOR

## 获取根状态机，递归向上查找并返回根状态机实例
## [br][br][b]返回:[/b] 根状态机实例
func _get_root_statemachine():
	var current = self
	while current is StateHfsm:
		if current is StateMachineHfsm:
			if current.is_root:
				return current
		else:
			current = current.get_parent()
	push_error("HFSM状态: 未找到标记为根的状态机，请确保根状态机的is_root为true")
