## SORA @editing: Sora [br]
## @describe: 指定按键, 检查seekbox内的信息
extends ReactorExtension

@export var seek_box: SeekBox

func _listen():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !seek_box.seek_target.is_empty():
			seek_box.seek_target[-1].interact_activated.emit(binding_entity)
			seek_box.seek_target.pop_back()
