## EP0健治过场状态机 - 第一章与健治角色的初次见面剧情
##
## 该状态机实现了游戏第一章中玩家与健治角色初次见面的过场动画。
## 包含角色移动、对话交互和剧情推进的完整流程控制。
##
## 剧情流程：
## 1. [b]等待阶段[/b]：角色隐藏，等待10秒后自动开始
## 2. [b]移动阶段[/b]：健治移动到目标位置，支持玩家交互
## 3. [b]对话阶段[/b]：触发对话系统，暂停移动
## 4. [b]完成阶段[/b]：过场结束，设置后续交互状态
##
## 主要特性：
## - 基于导航系统的智能移动
## - 实时速度控制和碰撞避让
## - 动态对话触发和状态切换
## - 交互类型的自动配置
##
## 技术实现：
## - 集成 [CNavigationAgent] 组件的路径规划
## - 使用 [CInteractable] 组件的交互管理
## - 基于 [DialogueManager] 的对话系统
## - 支持 [CharacterBody2D] 的物理移动
##
## 架构设计：
## - 继承自 [RuntimeCutsceneSM] 基类
## - 使用 [annotation @tool] 支持编辑器功能
## - 集成多个ECS组件的协同工作
## - 基于信号的事件驱动机制
##
## [br][b]编辑者:[/b] Sora
@tool
extends RuntimeCutsceneSM

## 导航组件
## 
## 健治角色的导航组件，用于路径规划和移动控制，类型为 [CNavigationAgent]。
@export var c_navigation: CNavigationAgent

## 移动速度
## 
## 健治角色的移动速度（像素/秒）。
@export var movement_speed: int = 3000

## 目标标记点
## 
## 健治角色的移动目标位置标记，类型为 [Marker2D]。
@export var target_marker: Marker2D

## 交互组件
## 
## 健治角色的交互组件，用于对话和互动管理，类型为 [CInteractable]。
@export var c_interactable: CInteractable

## 真实朝向
## 
## 健治角色面向玩家时的方向向量，类型为 [Vector2]。
var true_toward: Vector2

## 交互对话
## 
## 健治角色的对话交互实例，类型为 [Interaction]。
var interaction_dialogue: Interaction

## 健治过场设置（重写方法）
## 
## 初始化健治过场的导航系统、速度控制和对话准备。
func _setup() -> void:
	super()
	c_navigation.nav_agent.velocity_computed.connect(func(safe_velocity):
		var character = c_navigation.component_body as CharacterBody2D
		if current_state_str == "cutscene_running":
			character.velocity = lerp(character.velocity, safe_velocity, 0.2)
		else:
			character.velocity = lerp(character.velocity, Vector2.ZERO, 0.2)
		character.move_and_slide()
	)
	await get_tree().create_timer(10).timeout
	interaction_dialogue = c_interactable.interaction_infos[0].interaction
	state_transition.emit("cutscene_running")

#region 等待过场启动状态（重写）

## 进入等待状态（重写方法）
## 
## 隐藏健治角色，等待过场正式开始。
func _enter_of_cutscene_waiting():
	c_navigation.component_owner.hide()

## 更新等待状态（重写方法）
## 
## 等待状态期间暂无特殊逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_waiting(_delta: float):
	pass

## 退出等待状态（重写方法）
## 
## 显示健治角色，准备开始移动。
func _exit_of_cutscene_waiting():
	c_navigation.component_owner.show()

#endregion

#region 过场播放状态（重写）

## 进入过场播放状态（重写方法）
## 
## 设置健治的对话标签、导航目标和交互事件监听。
func _enter_of_cutscene_running():
	interaction_dialogue.test_dialogue_label = "ep0_地铁内_与健治初见"
	var nav_agent = c_navigation.nav_agent
	var target_position = target_marker.global_position
	nav_agent.target_position = target_position
	
	interaction_dialogue.interact_activated.connect(func(entity: IEntity):
		true_toward = c_interactable.component_body.global_position.direction_to(entity.global_position).normalized()
		state_transition.emit("cutscene_pause")
	)

## 更新过场播放状态（重写方法）
## 
## 控制健治的移动逻辑，检测导航完成并处理物理移动。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_running(_delta: float):
	if c_navigation.nav_agent.is_navigation_finished():
		state_transition.emit("cutscene_finished")
		return

	var target_position: Vector2 = c_navigation.nav_agent.get_next_path_position()
	var target_direction: Vector2 = c_navigation.component_body.global_position.direction_to(target_position).normalized()
	var _owner_body = c_navigation.component_owner.main_control as CharacterBody2D
	var _velocity = target_direction * movement_speed * _delta

	if c_navigation.nav_agent.avoidance_enabled:
		c_navigation.nav_agent.velocity = _velocity
	else:
		_owner_body.velocity = _velocity
		_owner_body.move_and_slide()

## 退出过场播放状态（重写方法）
## 
## 配置健治的后续交互状态，切换为射线检测交互模式。
func _exit_of_cutscene_running():
	c_interactable.interaction_infos[0].is_passive = false
	c_interactable.change_interaction_info_type(0, InteractionRecord.InteractType.RayCasted)

	interaction_dialogue.test_dialogue_label = "ep0_隐藏_提前与健治交流"

#endregion

#region 过场完成状态（重写）

## 进入过场完成状态（重写方法）
## 
## 健治过场完成后的处理，当前无特殊逻辑。
func _enter_of_cutscene_finished():
	pass

## 更新过场完成状态（重写方法）
## 
## 过场完成状态的维持，当前无特殊逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_finished(_delta: float):
	pass

## 退出过场完成状态（重写方法）
## 
## 离开完成状态的清理，当前无特殊逻辑。
func _exit_of_cutscene_finished():
	pass

#endregion

#region 过场暂停状态（重写）

## 进入过场暂停状态（重写方法）
## 
## 进入对话状态，等待对话结束后自动恢复过场播放。
func _enter_of_cutscene_pause():
	await DialogueManager.dialogue_ended
	state_transition.emit("cutscene_running")
	
## 更新过场暂停状态（重写方法）
## 
## 暂停期间无需额外更新逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_pause(_delta: float):
	pass

## 退出过场暂停状态（重写方法）
## 
## 暂停结束的清理逻辑，当前无特殊处理。
func _exit_of_cutscene_pause():
	pass

#endregion
