## 法师技能释放触发行为
## 该行为用于触发法师的技能释放，比如持续咏唱法术、释放法术等
## 并根据技能的效果指定角色的动作
## [br][b]编辑者:[/b] Sora
extends ITriggerAction

@export var c_texture_controller: CTextureController

func _initialize():
	pass

func _trigger_update(...args):
	print("args: ", args)
	if args.size() > 0:
		var skill_id = args[0]
		match skill_id:
			0:
				s_魔法咏唱()
			1:
				s_攻击魔法()
			2:
				s_小型附魔()
			3:
				s_魔法盾()

func _trigger_update_finish():
	pass

## 尝试进行魔法咏唱动作
func s_魔法咏唱():
	var state = await c_texture_controller.packed_sprite.try_animation("魔法咏唱")
	if state:
		print("成功施展魔法咏唱")

func s_攻击魔法():
	var state = await c_texture_controller.packed_sprite.try_animation("攻击魔法")
	if state:
		print("成功施展攻击魔法")

func s_小型附魔():	
	var state = await c_texture_controller.packed_sprite.try_animation("小型附魔")
	if state:
		print("成功施展小型附魔")

func s_魔法盾():
	var state = await c_texture_controller.packed_sprite.try_animation("魔法盾")
	if state:
		print("成功施展魔法盾")
