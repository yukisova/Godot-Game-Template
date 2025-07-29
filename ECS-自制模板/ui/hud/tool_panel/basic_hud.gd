##@editing:	Sora
##@describe:	角色的基础hud
extends IHud

var binding_entity: Entity
@onready var health: ProgressBar = $Control/StatusPanel/VBoxContainer/Label/ProgressBar
@onready var magic: ProgressBar = $Control/StatusPanel/VBoxContainer/Label2/ProgressBar2
@onready var fitness: ProgressBar = $Control/StatusPanel/VBoxContainer/Label3/ProgressBar3

func _refresh():
	var status = binding_entity.list_base_components[IComponent.ComponentName.c_status] as C_Status
	var health_status = status.status_list[SoraConstant.StatusEnum.Health]
	var magic_status = status.status_list[SoraConstant.StatusEnum.Magic]
	var fitness_status = status.status_list[SoraConstant.StatusEnum.Fitness]
	
	health.max_value = health_status.max_value
	health.value = health_status.value
	
	magic.max_value = magic_status.max_value
	magic.value = magic_status.value
	
	fitness.max_value = fitness_status.max_value
	fitness.value = fitness_status.value
	
func _initialize():
	var status = binding_entity.list_base_components[IComponent.ComponentName.c_status] as C_Status
	
	status.status_list[SoraConstant.StatusEnum.Health].status_changed.connect(func(target_status:C_Status.StatusInfo):
		health.max_value = target_status.max_value
		health.value = target_status.value
		)
	status.status_list[SoraConstant.StatusEnum.Magic].status_changed.connect(func(target_status:C_Status.StatusInfo):
		magic.max_value = target_status.max_value
		magic.value = target_status.value
		)
	status.status_list[SoraConstant.StatusEnum.Fitness].status_changed.connect(func(target_status:C_Status.StatusInfo):
		fitness.max_value = target_status.max_value
		fitness.value = target_status.value
		)
	
