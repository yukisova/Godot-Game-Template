extends UIModel

## 当前正在运行的对话资源
var current_dialogue_resource: DialogueResource:
	set(value):
		current_dialogue_resource = value
		if current_dialogue_resource:
			hud_controller.start(current_dialogue_resource, "caption_test")

var hud_controller: UIHudController

func _initialize(_context: Dictionary):
	hud_controller = _context["hud_controller"]
	
	if not hud_controller.has_connections("caption_ended"):
		hud_controller.caption_ended.connect(_on_caption_ended)
		hud_controller.caption_changed.connect(_on_caption_changed)

func _on_caption_ended():
	current_dialogue_resource = null
	hud_controller.try_hide()

func _on_caption_changed(new_caption: DialogueResource):
	current_dialogue_resource = new_caption
