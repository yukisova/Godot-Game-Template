extends ISystem

@export var main_menu_scene: PackedScene
@export var all_hud: Dictionary[StringName, PackedScene]

var current_hud: Dictionary[StringName, IHud] = {}
var current_ui: IUi

func _enter_tree() -> void:
	Main.s_ui_spawner = self

func _setup():
	for key in all_hud:
		var hud = all_hud[key].instantiate()
		Launcher.main.ui_view.add_child(hud)
		current_hud[key] = hud
		current_hud[key].hide()

func _spawn_ui(scene: PackedScene) -> CanvasLayer:
	if scene == null:
		return null
	var canvas = scene.instantiate()
	if canvas is IUi:
		if current_ui:
			current_ui.queue_free()
		current_ui = canvas
		Launcher.main.ui_view.add_child(current_ui)
		current_ui.unspawned.connect(_unspawn_ui)
		return canvas
	else:
		canvas.queue_free()
		return null

func _hide_hud(except_hud_name: Array[StringName]):
	for hud_name in current_hud.keys():
		if except_hud_name.has(hud_name):
			current_hud[hud_name].show()
		else:
			current_hud[hud_name].hide()

func _unspawn_ui(target_ui: IUi):
	if target_ui == current_ui:
		target_ui.queue_free()

func _all_unspawn():
	for i in Launcher.main.ui_view.get_children():
		i.queue_free()

## 当系统完成加载的时候，进入主场景
func _loading_start_ui():
	_spawn_ui(main_menu_scene)
