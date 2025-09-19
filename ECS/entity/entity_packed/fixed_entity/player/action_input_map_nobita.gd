
extends ActionInputMap

func _match_action(action_id: int):
	match action_id:
		0:
			_primary_action()
		1:
			_secondary_action()
		2:
			_special_action()
		3:
			_skill_1()
		4:
			_skill_2()
		5:
			_state_1()
		6:
			_state_2()

func _trigger_update_finish():
	pass

func _primary_action():

	var equipment_extension: EquipmentExtension = c_status.get_status_extension(StatusExtension.ExtensionType.EQUIPMENT)
	if equipment_extension:
		if equipment_extension.current_attack_node:
			equipment_extension.current_attack_node._trigger_effect()
		else:
			print("没有当前攻击节点")
		print("你好")

func _secondary_action():
	var c_sound_emitter: CSoundEmitter = c_status.get_other_component(IComponent.ComponentName.C_SOUND_EMITTER)
	if c_sound_emitter:
		print("播放测试用的声音区域")
		c_sound_emitter.play_sound_static("footstep", 10, 300, 100, 1)

func _special_action():
	pass

func _skill_1():
	pass
func _skill_2():
	pass

## 进入加速状态
func _state_0():
	pass

## 进入蹲趴状态
func _state_1():
	pass

## 进入躲藏状态
func _state_2():
	pass
