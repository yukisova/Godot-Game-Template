## @editing: Sora \
## @describe: 发现了目标的存在的反应，？状态
@tool
extends StatePda

@export var label: Label
@export var text: String

func _enter():
	label.text = text 
