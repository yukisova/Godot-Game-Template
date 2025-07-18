## 音频总线系统，负责管理游戏中应当出现的背景音乐，音效等的混合
## sfx存在
class_name S_AudioMaster
extends ISystem

enum AudioBusEnum {
	MASTER, MUSIC, SFX
}

const MASTER = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

const bgm_player_num: int = 2 ## 用于淡入淡出
var current_bgm_player_index = 0
var bgm_players: Array[AudioStreamPlayer] = []

const sfx_player_num: int = 6
var sfx_players: Array[AudioStreamPlayer] = []

const fade_duration = 1.0

func _enter_tree() -> void:
	Main.s_audio_master = self

func _setup():
	for i in bgm_player_num:
		var bgm_player = AudioStreamPlayer.new()
		bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
		bgm_player.bus = MUSIC_BUS
		add_child(bgm_player)
		bgm_players.append(bgm_player)
	for i in sfx_player_num:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.process_mode = Node.PROCESS_MODE_INHERIT
		sfx_player.bus = SFX_BUS
		add_child(sfx_player)
		sfx_players.append(sfx_player)

func play_music_fade_in(_audio_player: AudioStreamPlayer):
	_audio_player.play()
	var tween: Tween = create_tween()
	tween.tween_property(_audio_player, "volume_db", 0, fade_duration)
	
func play_music(_audio: AudioStream):
	var current_bgm_player = bgm_players[current_bgm_player_index]
	if current_bgm_player.stream == _audio:
		return
	current_bgm_player_index = (current_bgm_player_index + 1) % 2
	var next_bgm_player = bgm_players[current_bgm_player_index]
	play_music_fade_out(current_bgm_player)
	next_bgm_player.stream = _audio
	play_music_fade_in(next_bgm_player)

func play_music_fade_out(_audio_player: AudioStreamPlayer):
	var tween: Tween = create_tween()
	tween.tween_property(_audio_player, "volume_db", -40, fade_duration)
	await tween.finished
	_audio_player.stop()
	_audio_player.stream = null

func _set_volume(target_bus: AudioBusEnum, linear_vol: float):
	var db_vol = linear_to_db(linear_vol)
	match target_bus:
		AudioBusEnum.MASTER:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER), db_vol)
		AudioBusEnum.MUSIC:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), db_vol)
		AudioBusEnum.SFX:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), db_vol)
		
