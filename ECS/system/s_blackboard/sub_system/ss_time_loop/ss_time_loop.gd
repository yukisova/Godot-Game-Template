## 时间循环子系统 - 游戏内时间管理和日夜循环
## 该子系统负责管理游戏内的时间流逝，提供日夜循环和时间事件触发功能
## 集成了实时时间更新、滤镜效果切换和存档系统支持
## 核心功能：游戏内时间的实时更新和管理、基于游戏状态的时间流速控制、日夜循环的视觉效果切换
## 主要特性：24小时制时间系统（1440分钟）、与游戏状态机的集成控制、自动的地图滤镜效果更新
## 时间计算：使用分钟为基础单位（0-1439）、每秒游戏时间对应1分钟游戏内时间
## 架构设计：继承自 [ISubSystem] 基类，使用 [signal time_updated] 进行时间广播
## [br][b]编辑者:[/b] Sora
class_name SSTimeLoop
extends ISubSystem

## 时间更新信号
## 当游戏内时间发生变化时发出
## [param time]: 当前游戏时间（分钟，0-1439），类型为 [int]
signal time_updated(time: int)

## 上次记录的系统时间
## 用于计算时间差值的系统时间戳（秒）
var past_time: int

## 当前游戏内真实时间
## 游戏内的当前时间（分钟制，0-1439），设置时自动触发相关更新
var real_time: int:
	set(v):
		var new_time = v % 1440
		if real_time != new_time:  # 避免重复更新
			real_time = new_time
			time_updated.emit(real_time)

## 设置子系统的关键字标识符
func _enter_tree() -> void:
	keyword = SubSystemType.TIME_LOOP

#region 时间系统的实现

## 初始化时间系统的基础参数
func _setup():
	@warning_ignore("integer_division")
	past_time = Time.get_ticks_msec() / 1000

## 每帧更新游戏内时间，只在正常游戏状态下推进时间
## [param _delta]: 帧时间间隔，类型为 [float]
func _update(_delta: float) -> void:
	@warning_ignore("integer_division")
	var current_time = Time.get_ticks_msec() / 1000
	if current_time != past_time:
		past_time = current_time
		if SGameState.state_machine.get_leaf_state() is GamingStateNormal:
			real_time += 1

#endregion

#region 存档系统

## 保存当前的游戏时间到存档文件
## [param _data]: 存档数据文件，类型为 [SavedDataFile]
## [br][br][b]返回:[/b] [Dictionary] 包含时间数据的字典
func _save_as(_data: SavedDataFile) -> Dictionary:
	var result = {}
	result["real_time"] = real_time
	return {
		keyword:result
	}

## 从存档文件加载游戏时间
## [param data]: 存档数据文件，类型为 [SavedDataFile]
func _load_by(data: SavedDataFile):
	pass

#endregion
