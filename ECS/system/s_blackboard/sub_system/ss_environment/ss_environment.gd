## 环境状态子系统
## 负责管理环境状态，如天气、灯光状态，以及玩家的隐藏状态等

class_name SSEnvironment
extends ISubSystem

signal player_seek_state_changed(player: IEntity, seek_state: bool)

signal enemy_notice_player(enemy: IEntity, player: IEntity)
signal enemy_lost_player(enemy: IEntity, player: IEntity)

## 注意到目标的敌人列表
## FIXME 目前暂以单人模式为基准，后续需要优化
var notice_target_enemy_list: Array[IEntity] = []
var current_player: IEntity = null

func _enter_tree() -> void:
	keyword = SubSystemType.ENVIRONMENT
	
	enemy_notice_player.connect(_on_enemy_notice_player)
	enemy_lost_player.connect(_on_enemy_lost_player)

func _setup():
	current_player = SMainController._get_player_info_by_index(0)

func _update(_delta: float) -> void:
	pass

func _on_enemy_notice_player(enemy: IEntity, _player: IEntity) -> void:
	var flag = notice_target_enemy_list.is_empty()
	if current_player == _player and !notice_target_enemy_list.has(enemy):
		notice_target_enemy_list.append(enemy)
	if flag:
		player_seek_state_changed.emit(current_player, true)

func _on_enemy_lost_player(enemy: IEntity, _player: IEntity) -> void:
	if current_player == _player:
		notice_target_enemy_list.erase(enemy)
	var flag = notice_target_enemy_list.is_empty()
	if flag:
		player_seek_state_changed.emit(current_player, false)
