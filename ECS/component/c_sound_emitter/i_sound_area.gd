## 声音区域，用于表示声音的传播范围
## [br][b]编辑者:[/b] Sora
@tool
class_name ISoundArea    
extends Area2D

## 1. 声音有两种大类: 
## 突然的声音: 声音会在持续一段固定时间后消失，
## 持续的声音: 声音会持续一段时间后消失，但时间不固定，例如移动时的脚步声
## 忽大忽小的声音: 
## 有回音的声音:

signal sound_finished(sound: ISoundArea)

## 声音名称
var sound_name: String = ""

#region 声音信息
## 声音
var sound_collision: CollisionShape2D
## 提升与降低的速度
var sound_spread_speed: float

## 声音源的声音大小，在一开始的时候就确定了，不能轻易修改
var sound_force: float = 0

## 当前碰撞体主要跟踪的声音
var main_sound: SoundInfo
## 声音队列，用于存储持续时间长于主声音的声音，当主声音完成后，会将队列中范围最长的声音加入主声音
var sound_queue: Array[SoundInfo]

## 当前声音的扩散范围，会持续与主声音的信息进行比对
var current_sound_range: float = 0:
	set(v):
		current_sound_range = v
		if current_sound_range < 0:
			## 如果当前声音范围小于0，则设置为0，会在下一帧发送信号，告诉声音已经彻底结束
			current_sound_range = 0
		sound_collision.shape.radius = current_sound_range

class SoundInfo:
	var sound_keep_time: float = 0:
		set(v):
			sound_keep_time = v
			if sound_keep_time <= 0:
				sound_keep_time = 0
	var sound_range: float

	enum SoundFlag {
		Back,
		Forward,
		Equal,
	}
	
	func _init(_keep_time: float, _range: float):
		sound_keep_time = _keep_time
		sound_range = _range

	## 检查声音是否在持续
	func check_flag(current_range: float) -> SoundFlag:
		## 如果当前声音范围小于主声音的范围，则说明声音要进行前进
		if current_range < sound_range and current_range < sound_range - 10 and sound_keep_time > 0:
			return SoundFlag.Forward
		## 如果当前声音范围大于主声音的范围，则说明声音要进行后退
		elif current_range > sound_range and current_range > sound_range + 10 or sound_keep_time <= 0:
			return SoundFlag.Back
		## 如果当前声音范围与主声音的范围相同，则说明声音可以直接相等于sound_range，防止抖动
		else:
			return SoundFlag.Equal
#endregion

func _ready():
	if Engine.is_editor_hint(): return
	collision_layer = Main.PhysicsLayer.Sound
	collision_mask = Main.PhysicsLayer.Sound
	sound_collision = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 0
	sound_collision.shape = circle
	add_child(sound_collision)

## 初始化声音
func _sound_initialize(context: Dictionary):
	sound_name = context.get("sound_name", "")
	sound_spread_speed = context.get("sound_spread_speed", 0)
	sound_force = context.get("sound_force", 0)
	
	var new_sound_keep_time = context.get("sound_keep_time", 0)
	var new_sound_range = context.get("sound_range", 0)
	var new_sound = SoundInfo.new(new_sound_keep_time, new_sound_range)
	main_sound = new_sound

## 更新声音的内容
func _sound_update(context: Dictionary):
	var new_sound_keep_time = context.get("sound_keep_time", 0)
	var new_sound_range = context.get("sound_range", 0)
	
	var new_sound = SoundInfo.new(new_sound_keep_time, new_sound_range)
	
	if main_sound:
		## 如果主声音的持续时间与范围均大于新声音的持续时间，则不需要进行更新，因为不会被新声音覆盖
		if main_sound.sound_keep_time > new_sound_keep_time and main_sound.sound_range >= new_sound_range:
			return
		## 如果主声音的范围小于新声音的范围，则将原本的主声音加入队列，并设置为新声音为主声音
		elif main_sound.sound_range < new_sound_range:
			sound_queue.push_front(main_sound)
			main_sound = new_sound
		## 如果主声音的持续时间小于新声音的持续时间，则将新声音加入队列，因为新声音有概率会覆盖主声音
		elif main_sound.sound_keep_time < new_sound_keep_time:
			sound_queue.push_front(new_sound)
	else:
		## 如果主声音为空，说明当前已经没有任何声音，则设置新声音为主声音
		main_sound = new_sound
	
	
func _process(delta: float) -> void:
	_update(delta)

func _update(_delta: float):
	if main_sound:
		match main_sound.check_flag(current_sound_range):
			SoundInfo.SoundFlag.Forward:
				current_sound_range += sound_spread_speed * 10 * _delta
			SoundInfo.SoundFlag.Back:
				current_sound_range -= sound_spread_speed * 10 * _delta
			SoundInfo.SoundFlag.Equal:
				current_sound_range = main_sound.sound_range
	else:
		current_sound_range -= sound_spread_speed * 10 * _delta

	## 如果主声音不为空，则更新主声音的持续时间
	if main_sound:
		main_sound.sound_keep_time -= _delta
	
	## 如果队列中的声音持续时间小于0，则将该声音从队列中移除
	var await_remove_sound: Array[SoundInfo] = []
	for i in sound_queue:
		i.sound_keep_time -= _delta
		if i.sound_keep_time <= 0:
			await_remove_sound.append(i)

	for i in await_remove_sound:
		sound_queue.erase(i)
	
	## 如果主声音的持续时间小于0，则将主声音从队列中移除，并设置为队列中范围最长的声音为主声音
	if main_sound and main_sound.sound_keep_time <= 0:
		var longest_sound: SoundInfo = null
		for i in sound_queue:
			if longest_sound == null or i.sound_range > longest_sound.sound_range:
				longest_sound = i
		if longest_sound:
			main_sound = longest_sound
			sound_queue.erase(longest_sound)
	
	## 如果当前声音范围为0，则认为声音已经彻底结束，发出信号
	if current_sound_range == 0:
		sound_finished.emit(self)
