## SORA @editing: Sora [br]
## @describe: 交互组件，可以实现基于被动或主动的交互

## TODO 见鬼
@tool
class_name C_Interactable
extends IComponent

@export var interactions_resources: Array[InteractionRecord]

var interaction_infos: Array[InteractionRecordInfo] = []

class InteractionRecordInfo:
	var interaction: PassiveInteraction
	var interact_box: InteractBox
	var is_passive: bool
	var interact_type: InteractionRecord.InteractType

	func _init(_interaction: PassiveInteraction, _interact_box: InteractBox, _is_passive: bool, _interact_type: InteractionRecord.InteractType) -> void:
		interaction = _interaction
		interact_box = _interact_box
		is_passive = _is_passive
		interact_type = _interact_type

func _enter_tree() -> void:
	component_name = ComponentName.c_interaction

## 初始化: 绑定交互的目标
func _initialize(_owner: Entity):
	super._initialize(_owner)
	
	interaction_infos.clear()
	interactions_resources = interactions_resources.filter(func(abc): return abc != null)
	for i in interactions_resources:
		var interaction_record_info = InteractionRecordInfo.new(
			get_node(i.interaction) as PassiveInteraction,
			get_node(i.interact_box) as InteractBox if i.interact_type != InteractionRecord.InteractType.RayCasted else null,
			i.is_passive,
			i.interact_type
		)
		interaction_infos.append(interaction_record_info)
	
	for interaction_action in interaction_infos:
		interaction_action.interaction.binding_entity = component_owner
		register_inteactable_area(interaction_action)
	

func register_inteactable_area(interaction_info: InteractionRecordInfo):
	var final_body: CollisionObject2D
	if interaction_info.interact_type == InteractionRecord.InteractType.RayCasted:
		final_body = component_body
	else:
		final_body = interaction_info.interact_box
	
	match interaction_info.interact_type:
		InteractionRecord.InteractType.BodyEntered:
			final_body.body_entered.connect(func(_body: Node2D):
				if _body.is_in_group("player"):
					if interaction_info.is_passive:
						interaction_info.interaction.interact_activated.emit(_body.get_parent())
					else:
						var entity = _body.owner as Entity
						var c_input_reactor: C_InputReactor = entity.list_base_components.get(IComponent.ComponentName.c_input_reactor)
						if c_input_reactor:
							c_input_reactor.interact_obj = interaction_info.interaction
			)
			final_body.body_exited.connect(func(_body: Node2D):
				if _body.is_in_group("player"):
					interaction_info.interaction.interact_deactivated.emit()
					if not interaction_info.is_passive:
						var entity = _body.owner as Entity
						var c_input_reactor: C_InputReactor = entity.list_base_components.get(IComponent.ComponentName.c_input_reactor)
						if c_input_reactor:
							c_input_reactor.interact_obj = null
			)
		InteractionRecord.InteractType.AreaEntered:
			final_body.area_entered.connect(func(_area: Area2D):
				if _area is SeekBox:
					_area.seek_target.append(interaction_info.interaction)
			)
			final_body.area_exited.connect(func(_area: Area2D):
				if _area is SeekBox:
					_area.seek_target.erase(interaction_info.interaction)
			)
		InteractionRecord.InteractType.RayCasted:
			if final_body is not InteractBox:
				component_owner.entity_ray_interact.connect(func(interact_source: Entity):
					interaction_info.interaction.interact_activated.emit(interact_source)
				)
			else:
				print("见了鬼")
