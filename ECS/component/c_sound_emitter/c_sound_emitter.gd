## 声音发射器，可以根据需要发射声音，声音发射完毕后会自动销毁，可以同时发射多个声音，使用对象池方式进行管理
## 用于发射声音，是一个动态的Area2D，因为会
## [br][b]编辑者:[/b] Sora
@tool
class_name CSoundEmitter
extends IComponent

## 活动声音区域,key为声音名称，value为声音区域
var active_sound_areas: Dictionary[String, SoundArea] = {}
var available_sound_areas: Array[SoundArea] = []
@export var sound_pool_size: int = 5

func _enter_tree() -> void:
	component_name = ComponentName.C_SOUND_EMITTER

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)
	for i in sound_pool_size:
		_create_sound_area()

	initialize_complete.emit()

func _update(_delta: float):
	pass

func _fixed_update(_delta: float):
	pass

## 触发声音
## [param sound_name]: 声音名称
## [param sound_force]: 声音强度
## [param sound_range]: 声音范围
## [param sound_spread_time]: 声音扩散时间
## [param sound_keep_time]: 声音保持时间
func _trigger_sound(sound_name: String, sound_force: int, sound_range: float, sound_spread_time: float, sound_keep_time: float):
	## 1. 如果活动声音区域中已经存在该声音，则刷新该声音的内容
	if active_sound_areas.has(sound_name):
		active_sound_areas[sound_name].add_sound_info({
			"sound_force": sound_force,
			"sound_range": sound_range,
			"sound_spread_time": sound_spread_time,
			"sound_keep_time": sound_keep_time
		})
		return
	## 2. 如果可用声音区域为空，则创建一个新的声音区域
	if available_sound_areas.is_empty():
		_create_sound_area()
	## 3. 此时可用声音区域不为空，则从可用声音区域中获取一个声音区域，并设置相关的参数
	var sound_area = available_sound_areas.pop_front()
	sound_area.sound_name = sound_name
	sound_area.sound_force = sound_force
	sound_area.sound_range = sound_range
	sound_area.sound_spread_time = sound_spread_time
	sound_area.sound_keep_time = sound_keep_time
	## 3. 将声音区域放入活动声音区域中,并设置生效状态
	_spawn_sound_area(sound_area)

func _reset():
	pass

func _save():
	pass

func _load(_dict: Dictionary):
	pass

func _spawn_sound_area(sound_area: SoundArea):
	active_sound_areas[sound_area.sound_name] = sound_area
	sound_area.show()
	sound_area.monitorable = true
	sound_area.monitoring = true

func _create_sound_area():
	var sound_area = SoundArea.new()
	sound_area.sound_area_finished.connect(_on_sound_area_finished)
	add_child(sound_area)
	available_sound_areas.append(sound_area)

func _on_sound_area_finished(sound_area: SoundArea):
	active_sound_areas.erase(sound_area.sound_name)
	sound_area._reset_sound_info()
	sound_area.monitorable = false
	sound_area.monitoring = false
	sound_area.hide()
	available_sound_areas.append(sound_area)

