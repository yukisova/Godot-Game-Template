## 战士技能释放触发行为
## 该行为用于触发战士的技能释放，比如挥剑攻击、盾牌防御等
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
				s_下劈()
			1:
				s_上挑()
			2:
				s_横扫()
			3:
				s_刺击()
			4:
				s_盾牌防御()
	pass

func _trigger_update_finish():
	pass

func s_下劈():
	var state = await c_texture_controller.packed_sprite.try_animation("下劈")
	if state:
		print("成功施展下劈")

func s_上挑():
	var state = await c_texture_controller.packed_sprite.try_animation("上挑")
	if state:
		print("成功施展上挑")

func s_横扫():
	var state = await c_texture_controller.packed_sprite.try_animation("横扫")
	if state:
		print("成功施展横扫")

func s_刺击():
	var state = await c_texture_controller.packed_sprite.try_animation("刺击")
	if state:
		print("成功施展刺击")

func s_盾牌防御():
	var state = await c_texture_controller.packed_sprite.try_animation("盾牌防御")
	if state:
		print("成功施展盾牌防御")

func s_盾牌前顶():
	var state = await c_texture_controller.packed_sprite.try_animation("盾牌前顶")
	if state:
		print("成功施展盾牌前顶")

func s_盾反():
	var state = await c_texture_controller.packed_sprite.try_animation("盾反")
	if state:
		print("成功施展盾反")
