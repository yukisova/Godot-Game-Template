## 玩家空闲状态 - 玩家静止时的状态实现
## 表示玩家角色处于静止不动的状态，通常播放待机动画
## 状态特征：播放待机动画、监听移动输入、根据朝向调整角色方向
## 状态转换：检测到移动输入时切换到移动状态，触发交互或进入战斗
## [br][b]编辑者:[/b] Sora
@tool
class_name StateIdlePlayer
extends StateHfsm

## 移动策略组件，用于获取移动方向和检测移动输入
@export var vector_move: IUpdateAction

## 纹理组件，用于播放待机动画和控制角色朝向
@export var c_texture: CTextureController


## 状态更新，持续监听移动输入，当检测到移动时切换到移动状态
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	var move_vector = vector_move.move_vector as Vector2
	
	# 检测是否有移动输入
	if not move_vector.is_zero_approx():
		# 尝试切换到移动状态
		var move_state = get_transition_state("move")
		if move_state:
			state_transition.emit(move_state)

## 退出空闲状态，清理空闲状态相关设置
func _exit():
	print("玩家状态: 退出空闲状态")

## 根据方向向量获取方向字符串，将方向向量转换为可用于动画名称的方向字符串
## [param direction]: 方向向量，类型为 [Vector2]
## [br][br][b]返回:[/b] 方向字符串（如"up", "down", "left", "right"）
func get_direction_string(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y > 0 else "up"

func _fixed_update(_delta: float) -> void:
	pass

func _blur_update(_delta: float) -> void:
	pass

func _pause() -> void:
	pass

func _continue() -> void:
	pass	

func _enter() -> void:
	pass
