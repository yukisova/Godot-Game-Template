@tool
class_name CInteractable
extends IComponent

@export var interactions_resources: Array[InteractionRecord]

var interaction_infos: Dictionary[int, InteractionRecordInfo] = {}

class InteractionRecordInfo:
	var interaction: Interaction
	var interact_box: InteractBox
	var is_passive: bool
	var interact_type: InteractionRecord.InteractType = InteractionRecord.InteractType.Null:
		set(v):
			interact_type = v
			
	var callable_actived: Callable
	var callable_deactived: Callable

	func _init(_interaction: Interaction, _interact_box: InteractBox, _is_passive: bool, _interact_type: InteractionRecord.InteractType) -> void:
		interaction = _interaction
		interact_box = _interact_box
		is_passive = _is_passive
		interact_type = _interact_type

func _enter_tree() -> void:
	component_name = ComponentName.C_INTERACTABLE

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	interaction_infos.clear()
	interactions_resources = interactions_resources.filter(func(record): return record != null)
	for i in range(interactions_resources.size()):
		var record = interactions_resources[i]
		var interaction_record_info = InteractionRecordInfo.new(
			get_node(record.interaction) as Interaction,
			get_node(record.interact_box) as InteractBox if record.interact_type != InteractionRecord.InteractType.RayCasted else null,
			record.is_passive,
			record.interact_type
		)
		interaction_infos[i] = interaction_record_info
	
	for child in get_children():
		if child is Interaction:
			child.binding_entity = component_owner
	
	for interaction_action in interaction_infos.values():
		confirm_interact_callable(interaction_action)
	
	initialize_completed.emit()

func confirm_interact_callable(interaction_info: InteractionRecordInfo):
	match interaction_info.interact_type:
		InteractionRecord.InteractType.BodyEntered:
			interaction_info.callable_actived = Callable(func(_body: Node2D):
				if _body.is_in_group("player"):
					if interaction_info.is_passive:
						interaction_info.interaction.interact_activated.emit(_body.get_parent())
					else:
						var entity = _body.owner as IEntity
						var c_input_reactor: CInputReactor = entity.get_other_component(IComponent.ComponentName.C_INPUT_REACTOR)
						if c_input_reactor:
							c_input_reactor.interact_obj = interaction_info.interaction )
			interaction_info.callable_deactived = Callable(func(_body: Node2D):
				if _body.is_in_group("player"):
					interaction_info.interaction.interact_deactivated.emit()
					if not interaction_info.is_passive:
						var entity = _body.owner as IEntity
						var c_input_reactor: CInputReactor = entity.get_other_component(IComponent.ComponentName.C_INPUT_REACTOR)
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

func change_interaction_info_type(index: int, target_type: InteractionRecord.InteractType):
	var interaction_info = interaction_infos[index]
	if interaction_info.interact_type == target_type: return
	
	unregister_interactable_area(interaction_info)
	interaction_info.interact_type = target_type
	confirm_interact_callable(interaction_info)
	
	
