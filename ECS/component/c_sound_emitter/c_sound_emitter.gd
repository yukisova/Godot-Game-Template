## 声音发射器，可以根据需要发射声音，声音发射完毕后会自动销毁，可以同时发射多个声音，使用对象池方式进行管理
## 用于发射声音，是一个动态的Area2D，因为会
## [br][b]编辑者:[/b] Sora
@tool
class_name CSoundEmitter
extends IComponent

## 活动声音区域,key为声音名称，value为声音区域
var active_sound_areas: Dictionary[String, ISoundArea] = {}
var available_sound_areas: Array[ISoundArea] = []

## 动态声音标记，
var sound_flag_array: Array
var dynamic_sound: Dictionary[String, ISoundArea]

@export var sound_pool_size: int = 5

func _enter_tree() -> void:
	component_name = ComponentName.C_SOUND_EMITTER

func _initialize(_owner: IEntity, _load_data: Dictionary = {}):
	super._initialize(_owner, _load_data)

	initialize_completed.emit()

func _update(_delta: float):
	pass

## [param sound_name]: 声音名称
## [param sound_force]: 声音强度
## [param sound_range]: 声音范围
## [param sound_spread_time]: 声音扩散时间
## [param sound_keep_time]: 声音保持时间
func play_sound_static(sound_name: String, sound_force: int, sound_range: float, sound_spread_speed: float, sound_keep_time: float):
	## 参数验证
	if sound_name.is_empty():
		push_warning("CSoundEmitter: 声音名称不能为空")
		return
	if sound_range <= 0:
		push_warning("CSoundEmitter: 声音范围必须大于0")
		return

	## 1. 如果活动声音区域中已经存在该声音，则刷新该声音的内容
	if active_sound_areas.has(sound_name):
		print("已存在声音，刷新声音内容")
		active_sound_areas[sound_name]._sound_update({
			"sound_force": sound_force,
			"sound_range": sound_range,
			"sound_spread_speed": sound_spread_speed,
			"sound_keep_time": sound_keep_time
		})
		return
	## 2. 如果可用声音区域为空，则创建一个新的声音区域
	if available_sound_areas.is_empty():
		print("声音不够，新建来凑")
		_create_sound_area()
	print("新建声音区域")
	## 3. 此时可用声音区域不为空，则从可用声音区域中获取一个声音区域，并设置相关的参数
	var sound_area = available_sound_areas.pop_front()
	sound_area._sound_initialize({
		"sound_name": sound_name,
		"sound_force": sound_force,
		"sound_range": sound_range,
		"sound_keep_time": sound_keep_time,
		"sound_spread_speed": sound_spread_speed
	})
	_spawn_sound_area(sound_area)

## [param sound_name]: 要停止的声音名称
func stop_sound(sound_name: String):
	if active_sound_areas.has(sound_name):
		var sound_area = active_sound_areas[sound_name]
		_on_sound_area_finished(sound_area)

## 停止所有声音
func stop_all_sounds():
	for sound_name in active_sound_areas.keys():
		stop_sound(sound_name)

func _reset():
	stop_all_sounds()

func _save():
	pass

func _load(_dict: Dictionary):
	pass

func _spawn_sound_area(sound_area: ISoundArea):
	active_sound_areas[sound_area.sound_name] = sound_area
	sound_area.show()
	sound_area.process_mode = Node.PROCESS_MODE_INHERIT

func _create_sound_area():
	var sound_area: ISoundArea = ISoundArea.new()
	sound_area.hide()
	add_child(sound_area)
	# 连接声音完成信号
	sound_area.process_mode = Node.PROCESS_MODE_DISABLED
	sound_area.sound_finished.connect(_on_sound_area_finished)
	available_sound_areas.append(sound_area)

func _on_sound_area_finished(sound_area: ISoundArea):
	if active_sound_areas.has(sound_area.sound_name):
		active_sound_areas.erase(sound_area.sound_name)
	sound_area.hide()
	sound_area.process_mode = Node.PROCESS_MODE_DISABLED
	if sound_area not in available_sound_areas:
		available_sound_areas.append(sound_area)
