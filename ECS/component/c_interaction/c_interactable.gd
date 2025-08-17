## 交互组件 - 管理实体的交互行为和交互逻辑
##
## 该组件实现了复杂的实体交互系统，支持主动交互和被动交互两种模式。
## 可以处理多种交互触发条件，如碰撞检测、区域检测、射线检测等。
##
## 交互类型：
## - [constant InteractionRecord.InteractType.BodyEntered]：刚体进入触发的交互
## - [constant InteractionRecord.InteractType.AreaEntered]：区域进入触发的交互  
## - [constant InteractionRecord.InteractType.RayCasted]：射线检测触发的交互
## - [constant InteractionRecord.InteractType.Null]：禁用的交互
##
## 交互模式：
## - 被动交互：自动触发，无需玩家操作
## - 主动交互：需要玩家按键确认的交互
##
## 功能特性：
## - 多重交互记录管理
## - 动态交互类型切换
## - 可配置的交互条件
## - 与输入系统无缝集成
##
## 架构设计：
## - 基于 [InteractionRecord] 的配置管理
## - 通过 [class InteractionRecordInfo] 的运行时状态管理
## - 与 [CInputReactor] 组件的交互集成
##
## [br][b]编辑者:[/b] Sora
@tool
class_name CInteractable
extends IComponent

## 交互记录资源数组
## 
## 存储所有可用的交互配置记录，每个记录定义一种交互行为。
@export var interactions_resources: Array[InteractionRecord]

## 交互信息字典
## 
## 存储处理后的交互记录信息，按索引进行管理。
## 键为记录索引，值为对应的 [class InteractionRecordInfo] 实例。
var interaction_infos: Dictionary[int, InteractionRecordInfo] = {}

## 交互记录信息类
## 
## 包含交互的完整信息和运行时状态，管理交互的生命周期。
class InteractionRecordInfo:
	## 交互对象
	## 
	## 指向具体的交互逻辑实现，详见 [Interaction] 类。
	var interaction: Interaction
	
	## 交互检测区域
	## 
	## 用于检测交互触发的碰撞区域，详见 [InteractBox] 类。
	var interact_box: InteractBox
	
	## 是否为被动交互
	## 
	## true为被动交互（自动触发），false为主动交互（需要按键确认）。
	var is_passive: bool
	
	## 交互类型
	## 
	## 定义交互的触发方式，参见 [enum InteractionRecord.InteractType]。
	var interact_type: InteractionRecord.InteractType = InteractionRecord.InteractType.Null:
		set(v):
			interact_type = v
			
	## 激活时的回调函数
	## 
	## 当交互被激活时调用的回调函数。
	var callable_actived: Callable
	
	## 取消激活时的回调函数
	## 
	## 当交互被取消激活时调用的回调函数。
	var callable_deactived: Callable

	## 构造函数
	## 
	## 创建新的交互记录信息对象。
	## [param _interaction]: 交互对象，必须是 [Interaction] 类型
	## [param _interact_box]: 交互检测区域，必须是 [InteractBox] 类型
	## [param _is_passive]: 是否为被动交互
	## [param _interact_type]: 交互类型，参见 [enum InteractionRecord.InteractType]
	func _init(_interaction: Interaction, _interact_box: InteractBox, _is_passive: bool, _interact_type: InteractionRecord.InteractType) -> void:
		interaction = _interaction
		interact_box = _interact_box
		is_passive = _is_passive
		interact_type = _interact_type

func _enter_tree() -> void:
	component_name = ComponentName.C_INTERACTABLE

## 组件初始化
## 
## 解析交互记录资源，创建交互信息对象，并绑定相关的交互目标。
## [param _owner]: 拥有此组件的实体，必须是 [IEntity] 类型
## [param _load_data]: 可选的加载数据，用于恢复保存的状态
func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	
	# 清空现有交互信息
	interaction_infos.clear()
	
	# 过滤掉空的交互记录
	interactions_resources = interactions_resources.filter(func(record): return record != null)
	
	# 处理每个交互记录
	for i in range(interactions_resources.size()):
		var record = interactions_resources[i]
		var interaction_record_info = InteractionRecordInfo.new(
			get_node(record.interaction) as Interaction,
			get_node(record.interact_box) as InteractBox if record.interact_type != InteractionRecord.InteractType.RayCasted else null,
			record.is_passive,
			record.interact_type
		)
		interaction_infos[i] = interaction_record_info
	
	# 绑定所有被动交互对象到实体
	for child in get_children():
		if child is Interaction:
			child.binding_entity = component_owner
	
	# 为每个交互信息确认回调函数
	for interaction_action in interaction_infos.values():
		confirm_interact_callable(interaction_action)
	
	initialize_complete.emit()

## 确认交互回调函数
## 
## 根据交互类型设置相应的激活和取消激活回调函数。
## [param interaction_info]: 交互记录信息对象，类型为 [class InteractionRecordInfo]
func confirm_interact_callable(interaction_info: InteractionRecordInfo):
	match interaction_info.interact_type:
		InteractionRecord.InteractType.BodyEntered:
			interaction_info.callable_actived = Callable(func(_body: Node2D):
				if _body.is_in_group("player"):
					if interaction_info.is_passive:
						interaction_info.interaction.interact_activated.emit(_body.get_parent())
					else:
						var entity = _body.owner as IEntity
						var c_input_reactor: CInputReactor = entity.list_base_components.get(IComponent.ComponentName.C_INPUT_REACTOR)
						if c_input_reactor:
							c_input_reactor.interact_obj = interaction_info.interaction )
			interaction_info.callable_deactived = Callable(func(_body: Node2D):
				if _body.is_in_group("player"):
					interaction_info.interaction.interact_deactivated.emit()
					if not interaction_info.is_passive:
						var entity = _body.owner as IEntity
						var c_input_reactor: CInputReactor = entity.list_base_components.get(IComponent.ComponentName.C_INPUT_REACTOR)
						if c_input_reactor:
							c_input_reactor.interact_obj = null )
		InteractionRecord.InteractType.AreaEntered:
			interaction_info.callable_actived = Callable(func(_area: Area2D):
				if _area is SeekBox:
					_area.seek_target.append(interaction_info.interaction))
			interaction_info.callable_deactived = Callable(func(_area: Area2D):
				if _area is SeekBox:
					_area.seek_target.erase(interaction_info.interaction))
		InteractionRecord.InteractType.RayCasted:
			interaction_info.callable_actived = Callable(func(interact_source: IEntity):
				interaction_info.interaction.interact_activated.emit(interact_source))
			interaction_info.callable_deactived = Callable(func(_interact_source: IEntity):
				push_error("来来来来你告诉我这个方法咋触发")
				)
	register_inteactable_area(interaction_info)

## 注册交互区域
## 
## 将交互信息的回调函数连接到对应的碰撞体信号。
## [param interaction_info]: 交互记录信息对象，类型为 [class InteractionRecordInfo]
func register_inteactable_area(interaction_info: InteractionRecordInfo):
	var final_body: CollisionObject2D
	if interaction_info.interact_type == InteractionRecord.InteractType.RayCasted:
		final_body = component_body
	else:
		final_body = interaction_info.interact_box
	
	match interaction_info.interact_type:
		InteractionRecord.InteractType.BodyEntered:
			final_body.body_entered.connect(interaction_info.callable_actived)
			final_body.body_exited.connect(interaction_info.callable_deactived)
		InteractionRecord.InteractType.AreaEntered:
			final_body.area_entered.connect(interaction_info.callable_actived)
			final_body.area_exited.connect(interaction_info.callable_deactived)
		InteractionRecord.InteractType.RayCasted:
			if final_body is not InteractBox:
				component_owner.entity_ray_interact.connect(interaction_info.callable_actived)
			else:
				component_owner.entity_ray_interact.connect(interaction_info.callable_deactived)
		InteractionRecord.InteractType.Null:
			print("该交互记录已经被禁用")

## 注销交互区域
## 
## 断开交互信息的回调函数与碰撞体信号的连接。
## [param interaction_info]: 交互记录信息对象，类型为 [class InteractionRecordInfo]
func unregister_interactable_area(interaction_info: InteractionRecordInfo):
	var final_body: CollisionObject2D
	if interaction_info.interact_type == InteractionRecord.InteractType.RayCasted:
		final_body = component_body
	else:
		final_body = interaction_info.interact_box
	
	match interaction_info.interact_type:
		InteractionRecord.InteractType.BodyEntered:
			final_body.body_entered.disconnect(interaction_info.callable_actived)
			final_body.body_exited.disconnect(interaction_info.callable_deactived)
		InteractionRecord.InteractType.AreaEntered:
			final_body.area_entered.disconnect(interaction_info.callable_actived)
			final_body.area_exited.disconnect(interaction_info.callable_deactived)
		InteractionRecord.InteractType.RayCasted:
			if final_body is not InteractBox:
				component_owner.entity_ray_interact.disconnect(interaction_info.callable_actived)
			else:
				push_error("你确定？")
				component_owner.entity_ray_interact.disconnect(interaction_info.callable_deactived)
		InteractionRecord.InteractType.Null:
			print("该交互记录已经被禁用")

## 改变交互信息类型
## 
## 动态修改指定索引的交互记录的交互类型。
## [param index]: 交互记录的索引，必须是有效的交互记录索引
## [param target_type]: 目标交互类型，参见 [enum InteractionRecord.InteractType]
func change_interaction_info_type(index: int, target_type: InteractionRecord.InteractType):
	var interaction_info = interaction_infos[index]
	if interaction_info.interact_type == target_type: return
	
	unregister_interactable_area(interaction_info)
	interaction_info.interact_type = target_type
	confirm_interact_callable(interaction_info)
	
	
