## SORA @editing: Sora [br]
## @describe: 交互组件，可以实现基于被动或主动的交互
## 改进方向: 多个使用交互记录，可以自由决定是有哪些交互

@tool
class_name C_Interactable
extends IComponent

signal interact_activated ## 开始交互信号
signal interact_deactivated ## 取消交互信号

@export var interactions_resources: Array[InteractionRecord]
		

var interaction_infos: Array[InteractionRecordInfo] = []


class InteractionRecordInfo:
	var interaction: PassiveInteraction
	var interact_box: InteractBox
	var is_passive: bool
	var enable_body_entered: bool
	
	func _init(_interaction: PassiveInteraction, _interact_box: InteractBox, _is_passive: bool, _enable_body_entered: bool) -> void:
		interaction = _interaction
		interact_box = _interact_box
		is_passive = _is_passive
		enable_body_entered = _enable_body_entered

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
			get_node(i.interact_box) as InteractBox,
			i.is_passive,
			i.enable_body_entered
		)
		interaction_infos.append(interaction_record_info)
	
	for interaction_action in interaction_infos:
		interact_activated.connect(interaction_action.interaction._on_interact_activated.bind(self))
		interact_deactivated.connect(interaction_action.interaction._on_interact_deactivated.bind(self))
		interaction_action.interaction.binding_entity = component_owner
	
		register_inteactable_area(interaction_action)
	
	
		


func register_inteactable_area(interaction_info: InteractionRecordInfo):
	var final_body: CollisionObject2D = interaction_info.interact_box
	
	if final_body is Area2D: ## 保留用
		if interaction_info.enable_body_entered: ## 未禁用body检测
			final_body.body_entered.connect(func(_body: Node2D):
				if _body.is_in_group("player"):
					if interaction_info.is_passive:
						interact_activated.emit()
					else:
						var entity = _body.owner as Entity
						var c_input_reactor: C_InputReactor = entity.list_base_components.get(IComponent.ComponentName.c_input_reactor)
						if c_input_reactor:
							c_input_reactor.interact_obj = self
			)
			final_body.body_exited.connect(func(_body: Node2D):
				if _body.is_in_group("player"):
					interact_deactivated.emit()
					if not interaction_info.is_passive:
						var entity = _body.owner as Entity
						var c_input_reactor: C_InputReactor = entity.list_base_components.get(IComponent.ComponentName.c_input_reactor)
						if c_input_reactor:
							c_input_reactor.interact_obj = self
			)
		else:
			final_body.area_entered.connect(func(_area: Area2D):
				if _area is SeekBox:
					_area.seek_target.append(self)
				)
			final_body.area_exited.connect(func(_area: Area2D):
				if _area is SeekBox:
					_area.seek_target.erase(self)
				)
