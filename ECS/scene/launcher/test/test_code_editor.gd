## 代码编辑器测试场景脚本
## 演示 CodeEdit 控件的语法高亮、代码提示和编辑功能
extends CanvasLayer

@onready var code_edit: CodeEdit = $CodeEdit
@onready var info_label: Label = $InfoLabel
@onready var theme_selector: OptionButton = $UI/ThemeSelector
@onready var font_size_slider: HSlider = $UI/FontSizeSlider
@onready var line_numbers_checkbox: CheckBox = $UI/LineNumbersCheckbox
@onready var minimap_checkbox: CheckBox = $UI/MinimapCheckbox
@onready var word_wrap_checkbox: CheckBox = $UI/WordWrapCheckbox

# 代码补全相关变量
var completion_popup: PopupMenu
var current_suggestions: Array = []
var selected_suggestion_index: int = 0

# 预设的代码示例
var code_examples = {
	"gdscript": '''## GDScript 代码示例
extends Node2D

@export var speed: float = 100.0
@export var health: int = 100

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	print("节点已准备就绪")
	_setup_components()
	
func _process(delta: float) -> void:
	_handle_input()
	_update_movement(delta)
	
func _handle_input() -> void:
	if Input.is_action_pressed("ui_right"):
		position.x += speed * delta
	elif Input.is_action_pressed("ui_left"):
		position.x -= speed * delta
		
func _setup_components() -> void:
	if sprite:
		sprite.modulate = Color.RED
	if animation_player:
		animation_player.play("idle")
		
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
		
func heal(amount: int) -> void:
	health = min(health + amount, 100)
	print("生命值恢复: ", amount)'''
}

func _ready() -> void:
	_setup_code_edit()
	_setup_ui()
	_setup_completion_popup()
	_load_example_code("gdscript")

func _setup_code_edit() -> void:
	# 设置基本属性
	code_edit.gutters_draw_line_numbers = true
	code_edit.gutters_draw_fold_gutter = true
	code_edit.minimap_draw = true
	code_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	
	# 设置字体
	var font = preload("res://resource/resource_template/basic_theme.tres").default_font
	if font:
		code_edit.add_theme_font_override("font", font)
		code_edit.add_theme_font_size_override("font_size", 16)
	
	# 设置语法高亮
	code_edit.syntax_highlighter = CodeHighlighter.new()
	_setup_syntax_highlighter()
	
	# 设置代码提示
	_setup_code_completion()
	
	# 连接信号
	code_edit.text_changed.connect(_on_text_changed)
	code_edit.caret_changed.connect(_on_caret_changed)
	code_edit.gui_input.connect(_on_code_edit_input)

func _setup_syntax_highlighter() -> void:
	var highlighter = code_edit.syntax_highlighter
	
	# 设置颜色
	highlighter.add_color_region("\"", "\"", Color.YELLOW)  # 字符串
	highlighter.add_color_region("'", "'", Color.YELLOW)    # 字符串
	highlighter.add_color_region("#", "", Color.GRAY)       # 注释
	highlighter.add_color_region("//", "", Color.GRAY)      # 注释
	highlighter.add_color_region("/*", "*/", Color.GRAY)    # 多行注释
	
	# 设置关键字
	var keywords = [
		"extends", "class_name", "func", "var", "const", "if", "else", "elif",
		"for", "while", "match", "return", "break", "continue", "pass",
		"true", "false", "null", "self", "super", "static", "enum",
		"signal", "export", "onready", "tool", "remote", "master", "puppet"
	]
	
	for keyword in keywords:
		highlighter.add_keyword_color(keyword, Color.CYAN)
	
	# 设置内置函数
	var builtins = [
		"print", "assert", "push_error", "push_warning", "is_instance_valid",
		"get_node", "get_parent", "get_child", "add_child", "remove_child",
		"queue_free", "free", "get_tree", "get_viewport", "get_world_2d"
	]
	
	for builtin in builtins:
		highlighter.add_keyword_color(builtin, Color.ORANGE)

func _setup_code_completion() -> void:
	# 启用代码提示
	code_edit.code_completion_enabled = true
	
	# 设置基本的代码补全选项
	_setup_basic_completion()

func _is_word_character(char: String) -> bool:
	# 检查字符是否为单词字符
	return char.length() == 1 and (char.unicode_at(0) >= 65 and char.unicode_at(0) <= 90 or  # A-Z
								   char.unicode_at(0) >= 97 and char.unicode_at(0) <= 122 or # a-z
								   char.unicode_at(0) >= 48 and char.unicode_at(0) <= 57)    # 0-9

func _setup_basic_completion() -> void:
	# 设置基本的代码补全选项
	var basic_keywords = [
		"func", "var", "const", "if", "else", "elif", "for", "while", "match",
		"return", "break", "continue", "pass", "extends", "class_name", "signal",
		"export", "onready", "true", "false", "null", "self", "super"
	]
	
	for keyword in basic_keywords:
		code_edit.add_code_completion_option(CodeEdit.KIND_CLASS, keyword, keyword)

func _setup_completion_popup() -> void:
	# 创建代码补全弹出菜单
	completion_popup = PopupMenu.new()
	completion_popup.name = "CompletionPopup"
	code_edit.add_child(completion_popup)
	
	# 设置弹出菜单属性
	completion_popup.visible = false
	
	# 连接信号
	completion_popup.id_pressed.connect(_on_completion_item_selected)
	completion_popup.popup_hide.connect(_on_completion_popup_hide)

func _on_request_code_completion(force: bool) -> void:
	# 当用户请求代码补全时触发
	var current_text = code_edit.get_line(code_edit.get_caret_line())
	var caret_column = code_edit.get_caret_column()
	
	# 获取当前单词
	var current_word = _get_current_word(current_text, caret_column)
	
	# 根据当前语言提供相应的补全建议
	var current_language = _get_current_language()
	_provide_completion_suggestions(current_word, current_language)

func _get_current_word(line_text: String, caret_column: int) -> String:
	# 从当前行获取光标位置的单词
	var word_start = caret_column
	var word_end = caret_column
	
	# 向前查找单词开始
	while word_start > 0 and (_is_word_character(line_text[word_start - 1]) or line_text[word_start - 1] == "_"):
		word_start -= 1
	
	# 向后查找单词结束
	while word_end < line_text.length() and (_is_word_character(line_text[word_end]) or line_text[word_end] == "_"):
		word_end += 1
	
	return line_text.substr(word_start, word_end - word_start)

func _get_current_language() -> String:
	# 只支持GDScript
	return "gdscript"

func _provide_completion_suggestions(current_word: String, language: String) -> void:
	# 只提供GDScript补全建议
	var suggestions = _get_gdscript_suggestions(current_word)
	_show_completion_popup(suggestions)

func _get_gdscript_suggestions(word: String) -> Array:
	var suggestions = []
	
	# 根据输入提供智能建议
	if word.begins_with("func"):
		suggestions.append({"text": "func function_name():\n\tpass", "description": "Function Definition"})
	elif word.begins_with("var"):
		suggestions.append({"text": "var variable_name: Type = value", "description": "Variable Declaration"})
	elif word.begins_with("const"):
		suggestions.append({"text": "const CONSTANT_NAME: Type = value", "description": "Constant Declaration"})
	elif word.begins_with("if"):
		suggestions.append({"text": "if condition:\n\tpass", "description": "Conditional Statement"})
	elif word.begins_with("for"):
		suggestions.append({"text": "for item in collection:\n\tpass", "description": "Loop Statement"})
	elif word.begins_with("while"):
		suggestions.append({"text": "while condition:\n\tpass", "description": "While Loop"})
	elif word.begins_with("match"):
		suggestions.append({"text": "match value:\n\tpattern:\n\t\tpass", "description": "Match Statement"})
	
	return suggestions





func _setup_ui() -> void:
	# 设置主题选择器
	theme_selector.add_item("默认主题", 0)
	theme_selector.add_item("深色主题", 1)
	theme_selector.add_item("浅色主题", 2)
	theme_selector.item_selected.connect(_on_theme_changed)
	
	# 设置字体大小滑块
	font_size_slider.min_value = 8
	font_size_slider.max_value = 32
	font_size_slider.value = 16
	font_size_slider.value_changed.connect(_on_font_size_changed)
	
	# 设置复选框
	line_numbers_checkbox.button_pressed = true
	line_numbers_checkbox.toggled.connect(_on_line_numbers_toggled)
	
	minimap_checkbox.button_pressed = true
	minimap_checkbox.toggled.connect(_on_minimap_toggled)
	
	word_wrap_checkbox.button_pressed = false
	word_wrap_checkbox.toggled.connect(_on_word_wrap_toggled)

func _load_example_code(language: String) -> void:
	var language_key = language.to_lower()
	if language_key in code_examples:
		code_edit.text = code_examples[language_key]
		_update_info()

func _on_text_changed() -> void:
	_update_info()

func _on_caret_changed() -> void:
	_update_info()

func _on_code_edit_input(event: InputEvent) -> void:
	# 处理CodeEdit的输入事件
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			# 如果Tab键被按下且补全菜单不可见，触发代码补全
			if not completion_popup.visible:
				_trigger_code_completion()
				get_viewport().set_input_as_handled()
			# 如果补全菜单可见，让_unhandled_input处理

func _on_theme_changed(index: int) -> void:
	match index:
		0: # 默认主题
			_apply_default_theme()
		1: # 深色主题
			_apply_dark_theme()
		2: # 浅色主题
			_apply_light_theme()



func _on_font_size_changed(value: float) -> void:
	code_edit.add_theme_font_size_override("font_size", int(value))

func _on_line_numbers_toggled(button_pressed: bool) -> void:
	code_edit.gutters_draw_line_numbers = button_pressed

func _on_minimap_toggled(button_pressed: bool) -> void:
	code_edit.minimap_draw = button_pressed

func _on_word_wrap_toggled(button_pressed: bool) -> void:
	code_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY if button_pressed else TextEdit.LINE_WRAPPING_NONE

func _apply_default_theme() -> void:
	code_edit.add_theme_color_override("background_color", Color(0.2, 0.2, 0.2))
	code_edit.add_theme_color_override("font_color", Color.WHITE)
	code_edit.add_theme_color_override("line_number_color", Color.GRAY)

func _apply_dark_theme() -> void:
	code_edit.add_theme_color_override("background_color", Color(0.1, 0.1, 0.15))
	code_edit.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	code_edit.add_theme_color_override("line_number_color", Color(0.5, 0.5, 0.6))

func _apply_light_theme() -> void:
	code_edit.add_theme_color_override("background_color", Color(0.95, 0.95, 0.95))
	code_edit.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	code_edit.add_theme_color_override("line_number_color", Color(0.4, 0.4, 0.5))

func _update_info() -> void:
	var text = code_edit.text
	var lines = text.split("\n")
	var characters = text.length()
	var words = text.split(" ").size()
	var current_line = code_edit.get_caret_line() + 1
	var current_column = code_edit.get_caret_column() + 1
	
	info_label.text = "代码编辑器信息\n行数: %d | 字符数: %d | 单词数: %d\n当前位置: 第%d行, 第%d列" % [
		lines.size(), characters, words, current_line, current_column
	]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# 如果补全弹出菜单可见，处理导航
		if completion_popup.visible:
			match event.keycode:
				KEY_UP:
					# 向上选择
					selected_suggestion_index = max(0, selected_suggestion_index - 1)
					_update_completion_popup_selection()
					get_viewport().set_input_as_handled()
				KEY_DOWN:
					# 向下选择
					selected_suggestion_index = min(current_suggestions.size() - 1, selected_suggestion_index + 1)
					_update_completion_popup_selection()
					get_viewport().set_input_as_handled()
				KEY_ENTER, KEY_KP_ENTER:
					# 确认选择
					if selected_suggestion_index >= 0 and selected_suggestion_index < current_suggestions.size():
						_on_completion_item_selected(selected_suggestion_index)
					get_viewport().set_input_as_handled()
				KEY_ESCAPE:
					# 取消选择
					completion_popup.hide()
					current_suggestions.clear()
					get_viewport().set_input_as_handled()
				KEY_TAB:
					# Tab键确认选择
					if selected_suggestion_index >= 0 and selected_suggestion_index < current_suggestions.size():
						_on_completion_item_selected(selected_suggestion_index)
					get_viewport().set_input_as_handled()
			return
		
		# 常规快捷键处理
		match event.keycode:
			KEY_F1:
				# 切换主题
				var current_index = theme_selector.selected
				theme_selector.select((current_index + 1) % theme_selector.item_count)
				_on_theme_changed(theme_selector.selected)
			KEY_F2:
				# 重新加载GDScript示例
				_load_example_code("gdscript")
			KEY_F3:
				# 切换行号显示
				line_numbers_checkbox.button_pressed = !line_numbers_checkbox.button_pressed
			KEY_F4:
				# 切换小地图
				minimap_checkbox.button_pressed = !minimap_checkbox.button_pressed
			KEY_F5:
				# 切换自动换行
				word_wrap_checkbox.button_pressed = !word_wrap_checkbox.button_pressed
			KEY_F6:
				# 触发代码补全
				_trigger_code_completion()
			KEY_F7:
				# 测试代码补全插入
				_test_completion_insertion()
			KEY_F8:
				# 检查CodeEdit方法
				_check_code_edit_methods()

func _trigger_code_completion() -> void:
	# 手动触发代码补全
	var current_line = code_edit.get_caret_line()
	var current_column = code_edit.get_caret_column()
	var line_text = code_edit.get_line(current_line)
	
	# 获取当前单词
	var current_word = _get_current_word(line_text, current_column)
	var current_language = _get_current_language()
	
	# 获取补全建议
	current_suggestions = _get_simple_suggestions(current_word, current_language)
	
	# 显示补全弹出菜单
	if current_suggestions.size() > 0:
		_show_completion_popup(current_suggestions)
		print("Triggered code completion with " + str(current_suggestions.size()) + " suggestions")
	else:
		print("No completion suggestions available")

func _test_completion_insertion() -> void:
	# 测试代码补全插入功能
	print("=== Testing Code Completion Insertion ===")
	
	# 方法1: 直接设置文本
	print("Method 1: Direct text setting")
	var current_line = code_edit.get_caret_line()
	var original_text = code_edit.get_line(current_line)
	print("Original line: '" + original_text + "'")
	
	code_edit.set_line(current_line, original_text + " // TEST INSERTION")
	var new_text = code_edit.get_line(current_line)
	print("After insertion: '" + new_text + "'")
	
	# 方法2: 使用insert_text_at_caret (如果存在)
	print("Method 2: Using insert_text_at_caret")
	if code_edit.has_method("insert_text_at_caret"):
		code_edit.insert_text_at_caret(" // METHOD2")
		print("Method 2 completed")
	else:
		print("Method 2 not available")
	
	# 方法3: 使用我们自己的函数
	print("Method 3: Using our insertion function")
	_insert_completion_text("func test_function():\n\tprint('Hello, World!')\n\treturn true")
	
	print("=== Test completed ===")

func _check_code_edit_methods() -> void:
	# 检查CodeEdit的可用方法
	print("=== Checking CodeEdit Methods ===")
	
	# 检查基本方法
	var methods_to_check = [
		"set_line", "get_line", "set_caret_column", "get_caret_column",
		"get_caret_line", "set_caret_line", "insert_text_at_caret",
		"add_text", "set_text", "get_text"
	]
	
	for method in methods_to_check:
		if code_edit.has_method(method):
			print("✓ " + method + " is available")
		else:
			print("✗ " + method + " is NOT available")
	
	# 检查属性
	print("CodeEdit text length: " + str(code_edit.text.length()))
	print("CodeEdit line count: " + str(code_edit.get_line_count()))
	print("Current caret line: " + str(code_edit.get_caret_line()))
	print("Current caret column: " + str(code_edit.get_caret_column()))
	
	print("=== Method check completed ===")

func _show_completion_popup(suggestions: Array) -> void:
	# 清空弹出菜单
	completion_popup.clear()
	
	if suggestions.size() == 0:
		return
	
	# 添加建议到弹出菜单
	for i in range(suggestions.size()):
		var suggestion = suggestions[i]
		var display_text = suggestion.description + ": " + suggestion.text
		# 限制显示文本长度
		if display_text.length() > 80:
			display_text = display_text.substr(0, 77) + "..."
		completion_popup.add_item(display_text, i)
	
	# 计算弹出菜单位置
	var caret_line = code_edit.get_caret_line()
	var caret_column = code_edit.get_caret_column()
	
	# 估算光标位置（基于行高和字符宽度）
	var line_height = 20  # 估算行高
	var char_width = 8    # 估算字符宽度
	var x_offset = caret_column * char_width
	var y_offset = caret_line * line_height + line_height  # 向下偏移一行
	
	# 设置弹出菜单位置并确保不超出边界
	var menu_pos = Vector2(x_offset, y_offset)
	var code_edit_size = code_edit.size
	
	# 确保菜单不会超出CodeEdit的右边界
	if menu_pos.x + 300 > code_edit_size.x:
		menu_pos.x = code_edit_size.x - 300
	
	# 确保菜单不会超出CodeEdit的下边界
	if menu_pos.y + 200 > code_edit_size.y:
		menu_pos.y = y_offset - 200  # 显示在光标上方
	
	completion_popup.position = menu_pos
	completion_popup.popup()
	selected_suggestion_index = 0
	
	# 在控制台显示提示信息
	print("Code completion popup shown with " + str(suggestions.size()) + " suggestions")
	print("Use ↑/↓ to navigate, Enter/Tab to select, Esc to cancel")

func _on_completion_item_selected(id: int) -> void:
	# 当用户选择补全项时
	print("abc")
	if id >= 0 and id < current_suggestions.size():
		var suggestion = current_suggestions[id]
		print("Selected completion item: " + suggestion.description)
		_insert_completion_text(suggestion.text)
		completion_popup.hide()
		current_suggestions.clear()

func _on_completion_popup_hide() -> void:
	# 当弹出菜单隐藏时
	#current_suggestions.clear()
	pass

func _update_completion_popup_selection() -> void:
	# 更新弹出菜单的选择状态
	if completion_popup.visible and current_suggestions.size() > 0:
		print("Selected suggestion: " + str(selected_suggestion_index + 1) + "/" + str(current_suggestions.size()))
		# 这里可以添加视觉反馈，比如高亮显示当前选择项

func _insert_completion_text(text: String) -> void:
	# 插入补全文本到编辑器
	print("=== Starting text insertion ===")
	print("Text to insert: '" + text + "'")
	
	var current_line = code_edit.get_caret_line()
	var current_column = code_edit.get_caret_column()
	var line_text = code_edit.get_line(current_line)
	
	print("Before insertion - Line: " + str(current_line) + ", Column: " + str(current_column))
	print("Current line text: '" + line_text + "'")
	
	# 获取当前单词位置
	var word_start = _get_word_start_position(line_text, current_column)
	print("Word start position: " + str(word_start))
	
	# 删除当前单词
	if word_start < current_column:
		line_text = line_text.substr(0, word_start) + line_text.substr(current_column)
		code_edit.set_line(current_line, line_text)
		code_edit.set_caret_column(word_start)
		print("After word deletion: '" + line_text + "'")
	
	# 尝试多种插入方法
	print("Trying different insertion methods...")
	
	# 方法1: 直接设置行文本
	var new_line_text = line_text.substr(0, word_start) + text + line_text.substr(word_start)
	print("Method 1 - New line text: '" + new_line_text + "'")
	code_edit.set_line(current_line, new_line_text)
	
	# 验证方法1
	var verify_text1 = code_edit.get_line(current_line)
	print("Method 1 result: '" + verify_text1 + "'")
	
	# 方法2: 如果方法1失败，尝试使用text属性
	if verify_text1 != new_line_text:
		print("Method 1 failed, trying Method 2...")
		var all_text = code_edit.text
		var lines = all_text.split("\n")
		lines[current_line] = new_line_text
		code_edit.text = "\n".join(lines)
		print("Method 2 completed")
	
	# 设置光标位置
	var new_caret_column = word_start + text.length()
	code_edit.set_caret_column(new_caret_column)
	
	# 最终验证
	var final_text = code_edit.get_line(current_line)
	print("Final result: '" + final_text + "'")
	print("=== Text insertion completed ===")

func _get_word_start_position(line_text: String, caret_column: int) -> int:
	# 获取当前单词的开始位置
	var word_start = caret_column
	
	while word_start > 0 and (_is_word_character(line_text[word_start - 1]) or line_text[word_start - 1] == "_"):
		word_start -= 1
	
	return word_start

func _get_simple_suggestions(word: String, language: String) -> Array:
	var suggestions = []
	
	# 只提供GDScript建议
	if word.length() > 0:
		suggestions.append({"text": "func " + word + "():\n\tpass", "description": "Function Definition"})
		suggestions.append({"text": "var " + word + ": Type = value", "description": "Variable Declaration"})
		suggestions.append({"text": "const " + word.to_upper() + ": Type = value", "description": "Constant Declaration"})
	else:
		suggestions.append({"text": "func function_name():\n\tpass", "description": "Function Definition"})
		suggestions.append({"text": "var variable_name: Type = value", "description": "Variable Declaration"})
		suggestions.append({"text": "if condition:\n\tpass", "description": "Conditional Statement"})
		suggestions.append({"text": "for item in collection:\n\tpass", "description": "Loop Statement"})
		suggestions.append({"text": "extends Node2D", "description": "Class Extension"})
		suggestions.append({"text": "class_name ClassName", "description": "Class Name"})
	
	return suggestions
