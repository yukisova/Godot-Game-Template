##@editing:	Sora
##@describe:	用于玩家Entity的，攻击行为，目前每一次_effect间隔0.1s,-1点魔力
##			攻击方式1: 连续发射的水流，在有限的魔力下可以在地面形成一个区域
##			攻击方式2: 一个曲线发射的球体，落到地面会爆炸，并生成一个区域
##			攻击方式3: 散射的球体，一共三向
extends Action

@export var shoot_offset: float = 20

@export var projectile_scene: PackedScene
@export var spend_magic: float

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)

func _effect(..._args):
	if timer.is_stopped():
		var status = c_action.component_owner.list_base_components[IComponent.ComponentName.c_status] as C_Status
		var magic = status.status_list[SoraConstant.StatusEnum.Magic]
		if magic.value > spend_magic: ## 消耗法力
			magic.value = magic.value - spend_magic
			var projectile = projectile_scene.instantiate() as Entity
			
			var mouse_global = get_global_mouse_position()
			var start_direction = global_position.direction_to(mouse_global).normalized()
			var start_position = global_position + start_direction * shoot_offset
			
			var context = {
				"global_position": start_position,
				"start_direction": start_direction,
				"target_position": mouse_global
			}
			
			projectile._init_data_binding(context)
			
			SObjectPool.add_child(projectile)
			timer.start()
		
