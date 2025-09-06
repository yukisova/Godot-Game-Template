## 声音区域，用于表示声音的传播范围
## [br][b]编辑者:[/b] Sora
@tool
class_name SoundArea    
extends Area2D

## 声音区域生成信号，用于通知c_sound_emitter将其放入活动声音区域
signal sound_area_spawned

## 声音区域完成信号，用于通知c_sound_emitter将其放入可用声音区域
signal sound_area_finished

## 声音名称
var sound_name: String

var sound_info_list: Array[SoundInfo] = []

class SoundInfo:
	var sound_force: int
	var sound_range: float
	var sound_spread_time: float
	var sound_keep_time: float
	var sound_collision_shape: CollisionShape2D

	## 声音是否完成
	var sound_finished: bool = false

	func _init(context: Dictionary, collision_shape: CollisionShape2D):
		sound_force = context.get("sound_force", 0)
		sound_range = context.get("sound_range", 0)
		sound_spread_time = context.get("sound_spread_time", 0)
		sound_keep_time = context.get("sound_keep_time", 0)
		sound_collision_shape = collision_shape

## 可用碰撞形状
var available_collision_shapes: Array[CollisionShape2D] = []
## 活跃碰撞形状
var active_collision_shapes: Array[CollisionShape2D] = []

func _ready():
	if Engine.is_editor_hint(): return
	collision_layer = Main.PhysicsLayer.Sound
	collision_mask = Main.PhysicsLayer.Sound
	body_entered.connect(_on_body_entered)

## 添加新的声音来源的信息对象
## [param context]: 声音来源的信息上下文
func _add_sound_info(context: Dictionary):
	## 1. 创建新的碰撞形状
	if available_collision_shapes.is_empty():
		_create_collision_shape()
	var new_collision_shape = available_collision_shapes.pop_front()
	active_collision_shapes.append(new_collision_shape)
	## 2. 创建新声音来源的信息对象
	var sound_info = SoundInfo.new(context, new_collision_shape)
	sound_info_list.append(sound_info)

func _create_collision_shape():
	var new_collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 0
	new_collision_shape.shape = shape
	add_child(new_collision_shape)
	available_collision_shapes.append(new_collision_shape)

func _reset_sound_info():
	for sound_info in sound_info_list:
		sound_info.sound_collision_shape.queue_free()
	sound_info_list.clear()
	active_collision_shapes.clear()
	available_collision_shapes.clear()

## 声音区域扩散Tween
## [param sound_info]: 声音信息
func _sound_area_spread(sound_info: SoundInfo):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(sound_info.sound_collision_shape, "shape:radius", sound_info.sound_range, sound_info.sound_spread_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sound_info.sound_collision_shape, "shape:radius", 0, sound_info.sound_spread_time).set_delay(sound_info.sound_keep_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	active_collision_shapes.erase(sound_info.sound_collision_shape)
	available_collision_shapes.append(sound_info.sound_collision_shape)
	sound_info_list.erase(sound_info)
	_check_sound_finished()

func _check_sound_finished():
	if sound_info_list.is_empty():
		sound_area_finished.emit()

func _on_body_entered(body: Node2D):
	if body.get_parent() is IEntity:
		var entity = body.get_parent()
		print("声音区域进入: ", entity.name)
