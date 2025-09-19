## 层次化有限状态机（HFSM）- 支持多层嵌套的复合状态机实现
## 允许状态机作为状态存在于更高层的状态机中，实现复杂的嵌套状态管理
## HFSM特性：状态嵌套、状态过渡、初始状态、生命周期、调试支持
## 应用场景：AI行为树、游戏状态、角色状态、UI流程
## [br][b]编辑者:[/b] Sora
@tool
class_name StateMachineHfsm
extends StateHfsm

## 状态切换完成信号，当状态机完成状态切换后发出
signal state_transition_finished

## 初始状态节点路径，指定状态机启动时的初始状态，必须是直接子节点
@export_node_path("StateHfsm") var init_state: NodePath:
	set(value):
		if value.is_empty():
			init_state = NodePath()
			return
			
		# 校验路径深度：直接子节点路径格式应为 "子节点名"
		if value.get_name_count() != 1:
			push_error("HFSM状态机: 初始状态必须是直接子节点！")
			return
		
		# 编辑器中防止设置自身为初始状态
		if Engine.is_editor_hint():
			if value == self.get_path_to(self):
				push_error("HFSM状态机: 不能将自身设置为初始状态！")
				return
		init_state = value
	get:
		# 如果没有子节点，返回空路径
		if get_child_count() == 0:
			return ""
		# 如果没有设置初始状态，默认使用第一个子节点
		elif init_state == null:
			return get_path_to(get_child(0))
		else:
			return init_state

## 当前激活的状态，指向当前正在执行的子状态
var current_state: StateHfsm

## 是否为根状态机标志，标识此状态机是否为整个状态机层次结构的根节点
var is_root: bool = false

## 编辑器初始化，在编辑器中通知属性列表更新，确保初始状态选择器正常工作
func _enter_tree() -> void:
	if Engine.is_editor_hint():
		notify_property_list_changed()

## 状态机设置，初始化所有子状态，建立状态机层次结构和信号连接
func _setup() -> void:
	for child in get_children():
		if child is StateHfsm:
			# 设置子状态的归属状态机
			child.belong_state_machine = self
			# 连接状态过渡信号
			child.state_transition.connect(_on_state_transition)
			# 递归设置子状态
			child._setup()

## 状态过渡处理，处理子状态发出的状态切换请求，执行状态切换逻辑
## [param to_state]: 目标状态
func _on_state_transition(to_state):
	var from_state = current_state
	
	# 清理当前状态的PDA栈并退出
	from_state._clear_stack_and_exit()
	
	# 检查是否为有效的状态切换
	if to_state != from_state:
		current_state = to_state
		current_state._enter()
	else:
		push_error("HFSM状态机: 不允许状态切换到自身")
	
	# 发出状态切换完成信号
	state_transition_finished.emit()

## 进入状态机，激活初始状态，开始状态机的执行
func _enter():
	current_state = get_node(init_state)
	current_state._enter()

## 退出状态机，退出当前状态并清理状态引用
func _exit():
	if current_state:
		current_state._exit()
		current_state = null

## 固定更新，将物理帧更新传递给当前激活的状态
## [param _delta]: 物理帧时间间隔
func _fixed_update(_delta: float) -> void:
	if current_state:
		current_state._f_u(_delta)

## 状态更新，执行模糊更新和当前状态的主更新逻辑
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	# 执行状态机自身的模糊更新
	_blur_update(_delta)
	# 执行当前状态的主更新
	if current_state:
		current_state._u(_delta)

## 暂停状态机，将暂停指令传递给当前激活的状态
func _pause():
	if current_state:
		current_state._p()

## 获取当前激活状态
## [br][br][b]返回:[/b] 当前正在执行的状态
func _get_active_state() -> StateHfsm:
	return current_state

## 获取叶子状态，递归查找最底层的激活状态（非状态机的状态）
## [br][br][b]返回:[/b] 最底层的叶子状态
func _get_leaf_state() -> StateHfsm:
	var result = current_state
	
	# 递归向下查找，直到找到非状态机的叶子状态
	while result is StateMachineHfsm:
		result = result.current_state
	
	return result

func _blur_update(_delta: float) -> void:
	pass

func _continue() -> void:
	pass