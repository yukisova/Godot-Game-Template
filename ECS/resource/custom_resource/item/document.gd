class_name ItemDocument
extends Item

## 文档背景纹理
## 显示文档时使用的背景图片，用于营造不同文档类型的视觉效果
@export var document_background: Texture2D
@export var document_tag: String = "文档"
## 文档中的所有信息是否都可以被看见
@export var hide_info_disable: bool = false:
	set(v):
		if Engine.is_editor_hint():
			hide_info_disable = v
		else:
			if hide_info_disable:
				return
			else:
				hide_info_disable = v
				refresh_content()

## JSON文件路径
## 存储文档内容数据的JSON文件路径

const JSON_FILES: Dictionary[String, String] = {
	"文档": "res://resource/json/测试用文本.json"
}

## 缓存的文档内容
## 用于避免重复加载JSON文件，提高性能
var _cached_content: PackedStringArray = []
var _cache_dirty: bool = true

var document_content: PackedStringArray:
	get:
		# 如果缓存有效且内容不为空，直接返回缓存
		if not _cache_dirty and not _cached_content.is_empty():
			return _cached_content
		
		_cached_content = _load_document_content()
		_cache_dirty = false
		return _cached_content
	set(value):
		_cached_content = value
		_cache_dirty = false

## 私有方法：加载文档内容
## 返回值：String - 文档的文本内容
func _load_document_content() -> PackedStringArray:
	var JSON_FILE = JSON_FILES.get(document_tag, "")
	# 检查JSON文件是否存在
	if not FileAccess.file_exists(JSON_FILE) or JSON_FILE == "":
		push_error("Document JSON file not found: " + JSON_FILE)
		return ["[错误] 文档文件未找到"]
	
	# 读取JSON文件内容
	var file = FileAccess.open(JSON_FILE, FileAccess.READ)
	if file == null:
		push_error("Failed to open document file: " + JSON_FILE)
		return ["[错误] 无法打开文档文件"]
	
	var json_string = file.get_as_text()
	file.close()
	
	# 解析JSON数据
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse JSON in document file: " + JSON_FILE)
		return ["[错误] 文档文件格式错误"]
	
	var json_data = json.data
	
	# 检查JSON数据是否为字典格式
	if not json_data is Dictionary:
		push_error("JSON data is not a dictionary in file: " + JSON_FILE)
		return ["[错误] 文档数据格式错误"]
	
	# 查找指定ID的文档
	if not json_data.has(item_nick_name):
		push_warning("Document ID '" + item_nick_name + "' not found in " + JSON_FILE)
		return ["[警告] 文档ID \"" + item_nick_name + "\" 未找到"]
	
	var document_data = json_data[item_nick_name]
	
	# 检查文档数据格式
	if not document_data is Dictionary:
		push_error("Document data for ID '" + item_nick_name + "' is not a dictionary")
		return ["[错误] 文档数据结构错误"]
	
	# 提取文档文本内容
	if document_data.has("text"):
		var result = PackedStringArray(document_data["text"])
		if hide_info_disable:
			var hide_info = document_data.get("hide_info", [])
			result.append_array(hide_info)
		return result
	else:
		push_warning("Document ID '" + item_nick_name + "' has no 'text' field")
		return ["[警告] 文档内容为空"]

## 刷新文档内容缓存
## 强制重新加载JSON文件内容
func refresh_content() -> void:
	_cache_dirty = true
	# 触发getter重新加载
	var _unused = document_content

## 设置文档ID并刷新内容
## 参数：new_id - 新的文档ID
func set_document_id(new_id: String) -> void:
	if item_nick_name != new_id:
		item_nick_name = new_id
		refresh_content()
