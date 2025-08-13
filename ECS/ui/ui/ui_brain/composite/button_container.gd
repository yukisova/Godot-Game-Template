## 动态生成的自定义popum menu，目前的要求
## 1. 根据传入的数据生成一组按钮
class_name ButtonContainer
extends VBoxContainer

## 由外部传入，如果在外部传入了，则基于外部的按钮样式进行复制
@export var button_prototype: Button

func _ready() -> void:
	pass

class ButtonInfo:
	var button_name: String ## 按键的显示文字名
	var button_func: Callable ## 按键对接的方法
	var button_context: Array ## 按键的内容
	
	func _init(_button_context: Array, _button_func: Callable, _button_name: String) -> void:
		button_context = _button_context
		button_func = _button_func
		button_name = _button_name

## button_info的信息: 
func _generate(_button_info: Array[ButtonInfo],start_position: Vector2):
	global_position = start_position
	for i in _button_info:
		if not button_prototype:
			var new_button = FuncButton.new()
			new_button.text = i.button_name
			new_button.args = i.button_context
			new_button.pressed.connect(func():
				i.button_func.callv(new_button.args)
				queue_free()
			)
			add_child(new_button)

static func get_button_info_from(data: Array[Dictionary], args) -> Array[ButtonInfo]:
	var result: Array[ButtonInfo] = []
	for i in data:
		var button_info = ButtonInfo.new(args, i[Item.STR_FUNC] as Callable, i[Item.STR_TEXT])
		result.append(button_info)
	return result
		
