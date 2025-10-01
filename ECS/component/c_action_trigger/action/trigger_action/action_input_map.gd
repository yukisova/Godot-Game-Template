## 输入所会触发的技能列表，用于与input_reactor进行对接，实现不同按键按下时的不同逻辑
@abstract class_name ActionInputMap
extends ITriggerAction

@export var c_texture_controller: CTextureController
@export var c_status: CStatusList

func _initialize():
	pass

func _trigger_update(...args)  -> bool:
	if args.size() > 0:
		var action_id = args[0]
		await _match_action(action_id)
	_trigger_update_finish()
	return true

@abstract func _match_action(action_id: int)
