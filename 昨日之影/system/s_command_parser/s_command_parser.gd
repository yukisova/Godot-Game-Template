## @editing: Sora [br]
## @describe: 命令行系统, 在允许的情况下可以随时通过指定快捷键调出, 但是 [br]
##			  这玩意是小孩子不懂事，做着玩的，可能做完后在整个GMTK里都不咋用到
extends ISystem

signal command_editor_opened
signal command_editor_closed
signal command_editor_inputed(text: String)

@export_group("命令行面板","command_parser_")
@export var command_parser_canvas: CanvasLayer
@export var command_parser_editor: TextEdit

func _enter_tree() -> void:
	command_parser_canvas.hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func _setup():
	command_editor_opened.connect(_on_editor_opened)
	command_editor_closed.connect(_on_editor_closed)
	command_editor_inputed.connect(_on_parser_begin)

func _resetup():
	_on_editor_closed()

func _on_editor_opened():
	command_parser_canvas.show()
	process_mode = Node.PROCESS_MODE_INHERIT

func _on_editor_closed():
	command_parser_canvas.hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	_listen()

func _listen():
	if Input.is_action_just_pressed("ui_accept"):
		command_editor_inputed.emit()

## HACK 没决定好怎么做，保留用
func _on_parser_begin():
	if command_parser_editor.text.is_empty():
		return
