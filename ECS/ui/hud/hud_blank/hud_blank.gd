extends UIHudController

#region HUD生命周期

func _initialize():
	pass

## 更新当前显示的提示内容和状态
func _refresh():
	pass

func _ready() -> void:
	_load_blank_file("醒来吧，孩子。")
#endregion

const BLANK_FILE = "res://ui/hud/hud_blank/字幕文件.json"

func _load_blank_file(target_text: String):
	var file = FileAccess.open(BLANK_FILE, FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	if parse_result != OK:
		push_error("字幕文件解析失败")
		return
	var json_data = json.data
	if not json_data is Dictionary:
		push_error("字幕文件数据格式错误")
		return
	var blank_data = json_data[target_text]
	ui_view.update_blank_text(target_text, blank_data)
