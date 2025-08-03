## @editing: Sora [br]
## @describe: 测试用, 游戏入场的脚本, 基于Tween节点
extends Cutscene

@export_group("对话信息", "ui_dialogue_")
@export var ui_dialogue_packed_scene: PackedScene
@export var ui_dialogue_resource: DialogueResource
@export var ui_dialogue_label: Array[String]

## 在进入GamingNormal状态时自动调用
func _start():
	过场1_玩家苏醒()
	pass

## 入场之后，先要进行基础故事开场的说明
func 过场1_玩家苏醒():
	var transition_hud = SUiSpawner.current_hud.get(&"transition") as IHud ## 过渡ui
	SUiSpawner._hide_hud([&"transition"])
	transition_hud.black_rect.modulate = Color()
	
	var dialogue = SUiSpawner._spawn_ui(ui_dialogue_packed_scene)
	DialogueManager._start_balloon(dialogue, ui_dialogue_resource, ui_dialogue_label[0], [get_node(dict["玛格丽特睡觉"]) as Sprite2D, transition_hud])
	
	
	await DialogueManager.dialogue_ended
	await transition_hud.fade_in()
	
	SUiSpawner._hide_hud([&""])
	
	await get_tree().create_timer(30).timeout
	## 这里开始进行早餐
	dialogue = SUiSpawner._spawn_ui(ui_dialogue_packed_scene)
	SUiSpawner._hide_hud([&"transition"])
	
	
	transition_hud.black_rect.modulate = Color()
	DialogueManager._start_balloon(dialogue, ui_dialogue_resource, ui_dialogue_label[1], [get_node(dict["玛格丽特吃饭"]) as Sprite2D])
	await DialogueManager.dialogue_ended
	await transition_hud.fade_in()
