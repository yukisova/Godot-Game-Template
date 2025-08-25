## 哥布林近战的逻辑，原本是要做远程的哥布林的，但是时间已经不够了
## 并根据技能的效果指定角色的动作
## [br][b]编辑者:[/b] Sora
extends ITriggerAction

@export var c_texture_controller: CTextureController
@export var c_status: CStatusList

func _initialize():
	pass

func _trigger_update(...args):
	print("args: ", args)
	if args.size() > 0:
		var skill_id = args[0]
		match skill_id:
			_:
				s_哥布林近战()

func _trigger_update_finish():
	pass

## 尝试进行魔法咏唱动作
func s_哥布林近战():
	var state = await c_texture_controller.packed_sprite.try_animation("哥布林近战")
	if state:
		var equipment_extension: EquipmentExtension = c_status.status_extension[StatusExtension.ExtensionType.EQUIPMENT]
		if equipment_extension and equipment_extension.current_attack_node:
			equipment_extension.current_attack_node._trigger_effect()
		print("哥布林近战")
