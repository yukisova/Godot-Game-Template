## 音频总线系统，负责管理游戏中应当出现的背景音乐，音效等的混合
## sfx存在
extends ISystem

enum AudioBusEnum {
	master, music, sfx
}

const MASTER = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

func _enter_tree() -> void:
	Main.s_audio_master = self

func _setup():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = MUSIC_BUS
	add_child(bgm_player)
	
	for i in 5:
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		## sfx将会放在某个
		player.finished.connect(_on_sfx_finished.bind(player))

func _on_sfx_finished(player: AudioStreamPlayer):
	pass

func play_bgm(audio_stream: AudioStream, fade_time: float = 1.0):
	if bgm_player.playing:
		var tween = get_tree().create_tween()
		tween.tween.property(bgm_player, "bolume_db", -80.0, fade_time)
		tween.tween_callback(_stop_bgm)
		await tween.finished
	bgm_player.stream = audio_stream
	bgm_player.volume_db = 0.0
	bgm_player.play()
	bgm_player.volume_db = -30.0
	var tween_in = create_tween()
	tween_in.tween_property(bgm_player, "volume_db", 0.0, fade_time)
	
func _stop_bgm():
	bgm_player.stop()

func play_sfx(audio_stream: AudioStream, max_instances: int = 2):
	var count = 0
	for player in sfx_players:
		if player.playing and player.stream == audio_stream:
			count += 1
	if count >= max_instances:
		return
	
	for player in sfx_players:
		if not player.playing:
			player.stream = audio_stream
			player.play()
			break

func _set_volume(target_bus: AudioBusEnum, linear_vol: float):
	var db_vol = linear_to_db(linear_vol)
	match target_bus:
		AudioBusEnum.master:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER), db_vol)
		AudioBusEnum.music:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), db_vol)
		AudioBusEnum.sfx:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), db_vol)
		
