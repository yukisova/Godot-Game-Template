## [br][b]编辑者:[/b] Sora
class_name UiDialogue
extends UIController

#region 输入配置

## 推进对话的动作
## 
## 用于继续到下一句对话的输入动作，类型为 [StringName]。
@export var next_action: StringName = &"ui_accept"

## 跳过打字效果的动作
## 
## 用于快速显示完整对话文本的输入动作，类型为 [StringName]。
@export var skip_action: StringName = &"ui_cancel"

#endregion

#region 对话数据

## 对话资源
## 
## 当前正在播放的对话资源文件，类型为 [DialogueResource]。
var resource: DialogueResource

## 临时游戏状态
## 
## 传递给对话系统的临时状态数据，类型为 [Array]。
var temporary_game_states: Array = []

## 本地变量字典
## 
## 存储对话过程中的临时变量，类型为 [Dictionary]。
var locals: Dictionary = {}

#endregion

#region 对话状态

## 是否等待玩家输入
## 
## 标记当前是否在等待玩家操作。
var is_waiting_for_input: bool = false

## 是否将要隐藏气泡
## 
## 用于处理长时间变化时的界面隐藏机制。
var will_hide_balloon: bool = false

## 当前语言设置
## 
## 用于检测语言变化并更新显示，类型为 [String]。
var _locale: String = TranslationServer.get_locale()

#endregion

## 当前对话行
## 
## 当前正在显示的对话行，类型为 [DialogueLine]。
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			## 此处文件结束, 为了匹配目标的
			await get_tree().create_timer(0.1).timeout
			unspawn()
	get:
		return dialogue_line

## 冷却定时器
## 
## 用于在遇到状态变化时延迟隐藏对话气泡，类型为 [Timer]。
var mutation_cooldown: Timer = Timer.new()

## 对话气泡基础锚点
## 
## 对话界面的主容器控件，类型为 [Control]。
@onready var balloon: Control = %Balloon

## 角色名称标签
## 
## 显示当前说话角色名称的富文本标签，类型为 [RichTextLabel]。
@onready var character_label: RichTextLabel = %CharacterLabel

## 对话文本标签
## 
## 显示当前对话内容的专用标签组件，类型为 [DialogueLabel]。
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## 回应选择菜单
## 
## 玩家对话选择分支的菜单组件，类型为 [DialogueResponsesMenu]。
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu


func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)
	

func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()

## 开始对话
## 
## 启动指定的对话资源，开始对话流程。
## [param dialogue_resource]: 要播放的对话资源，类型为 [DialogueResource]
## [param title]: 对话的起始标识符，类型为 [String]
## [param extra_game_states]: 额外的游戏状态数组，类型为 [Array]
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	## HACK 个人写的修改部分, 旨在将该节点放入ui_view中
	if Main.ui_view != null:
		reparent(Main.ui_view)
	#else:
		#reparent(get_tree().current_scene)
	
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## 应用对话行
## 
## 根据新的 [DialogueLine] 更新对话界面的显示。
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for input
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
	elif dialogue_line.time != "":
		var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## 转到下一行
## 
## 跳转到指定ID的下一个对话行。
## [param next_id]: 下一个对话行的标识符，类型为 [String]
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()
	elif not balloon.visible:
		balloon.show()


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


#endregion
