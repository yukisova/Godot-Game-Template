##@editing:	Sora
##@describe:	用于玩家Entity的，积蓄法力行为，每一次_effect间隔0.1s,+1点魔力
extends Action

var timer: Timer

@export var cure_magic: float = 1

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)

func _effect(..._args):
	if timer.is_stopped():
		var status = c_action.component_owner.list_base_components[IComponent.ComponentName.c_status] as C_Status
		var magic = status.status_list[SoraConstant.StatusEnum.Magic]
		magic.value = magic.value + cure_magic
		timer.start()
