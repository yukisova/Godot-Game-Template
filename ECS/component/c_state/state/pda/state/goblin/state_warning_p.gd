## @editing: Sora \
## @describe: 注意到目标之后的反应，！状态
##			  会前往目标区域（自动判断）, 进行进一步的探
@tool
extends StatePda

@export var label: Label
@export var text: String

func _enter():
	label.text = text 
