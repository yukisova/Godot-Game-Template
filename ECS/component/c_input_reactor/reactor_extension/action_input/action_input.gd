extends ReactorExtension

## 输入参数，用于与
@export var input_parameter: Array[ActionInputRecord]

## 每帧调用的输入监听逻辑
func _setup():
	pass

func _listen():
	for parameter in input_parameter:
		if c_input_reactor.validate_control(parameter.input_name, parameter.input_type, false):
			var node = get_node(parameter.linkage_node) as ITriggerAction
			node._trigger_update.callv(parameter.input_parameter)
