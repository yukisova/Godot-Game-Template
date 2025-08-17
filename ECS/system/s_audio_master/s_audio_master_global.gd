## 音频主控系统 - 管理游戏中的背景音乐、音效和音频总线
##
## 该系统提供统一的音频管理接口，支持：
## - 背景音乐的无缝淡入淡出切换
## - 多个音效播放器的管理
## - 音频总线音量控制
## - 游戏暂停时的音频处理
##
## 音频架构：
## - Master总线：控制整体音量
## - Music总线：背景音乐专用，支持淡入淡出
## - SFX总线：音效专用，支持同时播放多个音效
##
## 核心特性：
## - 双背景音乐播放器实现无缝切换
## - 多音效播放器避免音效重叠问题
## - 自动音量管理和淡入淡出效果
## - 游戏暂停状态下的音频处理
##
## 技术实现：
## - 使用 [Tween] 实现音量淡入淡出
## - 基于 [AudioServer] 的音频总线管理
## - [Array] 管理多个 [AudioStreamPlayer]
##
## 架构设计：
## - 继承自 [ISystem] 基类
## - 基于 [enum AudioBusEnum] 的总线类型管理
## - 支持双播放器的音乐无缝切换
## - 多播放器的音效并发播放
##
## [br][b]编辑者:[/b] Sora
extends ISystem

#region 音频总线枚举和常量

## 音频总线类型枚举
## 
## 用于标识不同的音频通道和分类。
enum AudioBusEnum {
	MASTER,  ## 主音频总线 - 控制整体音量
	MUSIC,   ## 背景音乐总线 - 用于背景音乐播放
	SFX      ## 音效总线 - 用于游戏音效播放
}

## 音频总线名称常量
const MASTER = "Master"       ## 主总线名称，控制所有音频的整体音量
const MUSIC_BUS = "Music"     ## 音乐总线名称，专门用于背景音乐 
const SFX_BUS = "SFX"         ## 音效总线名称，专门用于游戏音效

#endregion

#region 背景音乐管理

## 背景音乐播放器数量
## 
## 使用双播放器实现淡入淡出效果，一个淡出的同时另一个淡入。
const bgm_player_num: int = 2

## 当前活跃的背景音乐播放器索引
## 
## 指示当前正在使用的背景音乐播放器。
var current_bgm_player_index = 0

## 背景音乐播放器数组
## 
## 包含用于淡入淡出切换的多个播放器，类型为 [Array] of [AudioStreamPlayer]。
var bgm_players: Array[AudioStreamPlayer] = []

#endregion

#region 音效管理

## 音效播放器数量
## 
## 支持同时播放多个音效，避免音效之间的冲突。
const sfx_player_num: int = 6

## 音效播放器数组
## 
## 管理所有可用的音效播放器，类型为 [Array] of [AudioStreamPlayer]。
var sfx_players: Array[AudioStreamPlayer] = []

#endregion

#region 音频效果配置

## 淡入淡出持续时间（秒）
## 
## 背景音乐切换时的淡入淡出动画持续时间。
const fade_duration = 1.0

#endregion

#region 系统生命周期

## 系统初始化
## 创建背景音乐和音效播放器
func _setup():
	print("音频系统: 开始初始化")
	
	# 创建背景音乐播放器
	for i in bgm_player_num:
		var bgm_player = AudioStreamPlayer.new()
		bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS  # 即使游戏暂停也继续播放
		bgm_player.bus = MUSIC_BUS
		bgm_player.volume_db = -40  # 初始音量为静音，用于淡入效果
		add_child(bgm_player)
		bgm_players.append(bgm_player)
	
	# 创建音效播放器
	for i in sfx_player_num:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.process_mode = Node.PROCESS_MODE_INHERIT  # 跟随游戏暂停状态
		sfx_player.bus = SFX_BUS
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	
	print("音频系统: 初始化完成，创建了 ", bgm_player_num, " 个背景音乐播放器和 ", sfx_player_num, " 个音效播放器")

## 系统重置
## 停止所有音频播放
func _resetup():
	print("音频系统: 开始重置")
	play_music(null)  # 停止背景音乐
	
	# 停止所有音效
	for sfx_player in sfx_players:
		if sfx_player.playing:
			sfx_player.stop()

#endregion

#region 背景音乐控制

## 背景音乐淡入播放
## 
## 从静音状态逐渐淡入到正常音量。
## [param _audio_player]: 要淡入的音频播放器，类型为 [AudioStreamPlayer]
func play_music_fade_in(_audio_player: AudioStreamPlayer):
	_audio_player.volume_db = -40  # 从静音开始
	_audio_player.play()
	
	var tween: Tween = create_tween()
	tween.tween_property(_audio_player, "volume_db", 0, fade_duration)

## 播放背景音乐
## 
## 支持无缝切换，新音乐淡入同时旧音乐淡出。
## [param _audio]: 要播放的音频流，传入null则停止音乐，类型为 [AudioStream]
func play_music(_audio: AudioStream):
	var current_bgm_player = bgm_players[current_bgm_player_index]
	
	# 如果是相同的音乐，则不进行切换
	if current_bgm_player.stream == _audio:
		return
	
	# 切换到下一个播放器
	current_bgm_player_index = (current_bgm_player_index + 1) % 2
	var next_bgm_player = bgm_players[current_bgm_player_index]
	
	# 淡出当前音乐，淡入新音乐
	play_music_fade_out(current_bgm_player)
	
	if _audio != null:
		next_bgm_player.stream = _audio
		play_music_fade_in(next_bgm_player)

## 背景音乐淡出停止
## 
## 从当前音量逐渐淡出到静音并停止播放。
## [param _audio_player]: 要淡出的音频播放器，类型为 [AudioStreamPlayer]
func play_music_fade_out(_audio_player: AudioStreamPlayer):
	var tween: Tween = create_tween()
	tween.tween_property(_audio_player, "volume_db", -40, fade_duration)
	await tween.finished
	_audio_player.stop()
	_audio_player.stream = null

#endregion

#region 音量控制

## 设置音频总线音量
## 
## 通过线性音量值调整指定音频总线的音量。
## [param target_bus]: 目标音频总线，类型为 [enum AudioBusEnum]
## [param linear_vol]: 线性音量值 (0.0-1.0)，会自动转换为分贝值
func _set_volume(target_bus: AudioBusEnum, linear_vol: float):
	var db_vol = linear_to_db(linear_vol)
	match target_bus:
		AudioBusEnum.MASTER:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER), db_vol)
		AudioBusEnum.MUSIC:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), db_vol)
		AudioBusEnum.SFX:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), db_vol)

#endregion
