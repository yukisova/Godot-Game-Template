class_name REActionInput
extends ReactorExtension

## 输入参数，用于与
@export var input_parameter: Array[ActionInputRecord]

## 针对pressed类型的输入，记录输入状态
var input_record_action: Array[ActionInputRecord] = []
var input_record_states: Array[ActionInputRecordState] = []

class ActionInputRecordState:
	var input_input_action: ActionInputRecord
	var input_state: bool

	func _init(_input_input_action: ActionInputRecord, _input_state: bool):
		input_input_action = _input_input_action
		input_state = _input_state

func _enter_tree() -> void:
	extention_type = REType.ACTION_INPUT

## 每帧调用的输入监听逻辑
func _late_initialize():
	refresh_input_record()

func refresh_input_record(): 
	input_record_action.clear()
	input_record_states.clear()
	for parameter in input_parameter:
		if parameter.input_type == SoraConstant.InputType.PRESSED:
			input_record_states.append(ActionInputRecordState.new(parameter, false))
		else:
			input_record_action.append(parameter)

func change_input_record(record_name: String, to_type: SoraConstant.InputType):
	var idx = input_parameter.find_custom(func(v): return v.input_name == record_name)
	if idx == -1:
		return
	else:
		var record = input_parameter[idx]
		record.input_type = to_type
		refresh_input_record()


## 监听输入
func _listen():
	## 针对released类型的输入，进行相关的特殊监听
	for input_record in input_record_action:
		if c_input_reactor.validate_control(input_record.input_name, input_record.input_type, false):
			var node = get_node(input_record.linkage_node) as ITriggerAction
			node._trigger_update.callv(input_record.input_parameter)
	for input_record_state in input_record_states:
		var input_record = input_record_state.input_input_action
		input_record_state.input_state = c_input_reactor.validate_control(input_record.input_name, input_record.input_type, false)

## 检查输入状态
func check_input_state(input_tag: String) -> bool:
	var find_index = input_record_states.find_custom(func(item: ActionInputRecordState): return item.input_input_action.input_name == input_tag)
	if find_index != -1:
		return input_record_states[find_index].input_state
	else:
		return false
