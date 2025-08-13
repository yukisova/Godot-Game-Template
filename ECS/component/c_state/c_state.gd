## @editing: Sora [br]
## @describe: 状态机组件 - 为实体提供复杂的状态管理和行为控制
## 
## 该组件实现了层次化有限状态机（HFSM）和下推自动机（PDA）的混合系统，
## 用于管理实体的复杂行为状态和状态转换逻辑。
## 
## 状态机类型：
## - HFSM（层次化有限状态机）：处理嵌套状态和并发状态
## - PDA（下推自动机）：处理状态栈和上下文相关的状态切换
## 
## 功能特性：
## - 多层状态嵌套支持
## - 状态栈管理
## - 自动状态切换
## - 游戏暂停/继续响应
## - 状态历史记录
## - 关键词索引的快速状态访问
@tool
class_name C_State
extends IComponent

## 根状态机
## 层次化有限状态机的根节点，管理主要的状态流转逻辑
@export var root_state_machine: StateMachineHfsm

## 下推状态集合节点
## 包含所有离散下推状态的容器节点
@export var pda_states: Node

## 下推状态字典
## 通过关键词快速访问PDA状态的字典
## 注意：keyword不是UUID，需要开发者手动维护唯一性
var pda_state_dict: Dictionary[StringName, StatePda]

func _enter_tree() -> void:
	component_name = ComponentName.c_state

## 组件初始化
## 收集所有下推状态，启动并初始化根状态机
## @param _owner: 拥有此组件的实体
func _initialize(_owner: IEntity):
	super._initialize(_owner)
	
	# 连接游戏暂停信号
	SGameState.game_paused.connect(_pause)
	
	# 收集所有下推状态
	for child in pda_states.get_children():
		if child is StatePda:
			pda_state_dict[child.keyword] = child
	
	# 初始化根状态机
	if root_state_machine:
		root_state_machine.is_root = true
		root_state_machine._setup()
		root_state_machine._enter()
	else:
		push_warning("状态机组件: 实体 ", component_owner.name, " 缺少根状态机")

## 状态机更新
## 每帧更新根状态机的逻辑
## @param _delta: 帧时间间隔
func _update(_delta: float):
	if root_state_machine:
		root_state_machine._update(_delta)

## 状态机物理更新
## 每个物理帧更新状态机的物理相关逻辑
## @param _delta: 物理帧时间间隔
func _fixed_update(_delta: float):
	if root_state_machine:
		root_state_machine._fixed_update(_delta)

## 暂停状态机
## 响应游戏暂停信号，暂停状态机的更新
func _pause():
	if root_state_machine:
		root_state_machine._pause()

## 继续状态机
## 响应游戏继续信号，恢复状态机的更新
func _continue():
	if root_state_machine:
		root_state_machine._continue()

## 获取指定关键词的PDA状态
## @param keyword: 状态关键词
## @return: 对应的StatePda对象，如果不存在则返回null
func get_pda_state(keyword: StringName) -> StatePda:
	return pda_state_dict.get(keyword)

## 获取当前活跃状态
## @return: 当前根状态机的活跃状态
func get_current_state():
	if root_state_machine:
		return root_state_machine._get_active_state()
	return null
