## 玩家空闲状态 - 玩家静止时的状态实现
##
## 该状态表示玩家角色处于静止不动的状态，通常播放待机动画。
## 当检测到玩家输入移动指令时，会自动切换到移动状态。
##
## 状态特征：
## - 播放待机/空闲动画
## - 监听移动输入
## - 根据朝向调整角色方向
## - 保持静止不动
##
## 状态转换条件：
## - 检测到移动输入 → 切换到移动状态
## - 触发交互 → 切换到交互状态
## - 进入战斗 → 切换到战斗状态
##
## 应用场景：
## - 玩家停止移动时
## - 游戏开始时的初始状态
## - 动画播放完毕后的默认状态
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 与 [MoveStrategy] 组件集成获取输入
## - 通过 [CTexture] 控制动画播放
##
## [br][b]编辑者:[/b] Sora
@tool
class_name StateIdlePlayer
extends StateHfsm

## 移动策略组件
## 
## 用于获取移动方向和检测移动输入，类型为 [MoveStrategy]。
@export var vector_move: MoveStrategy

## 纹理组件
## 
## 用于播放待机动画和控制角色朝向，类型为 [CTexture]。
@export var c_texture: CTexture

## 进入空闲状态（重写方法）
## 
## 根据当前朝向设置待机动画。
func _enter():
	var _direction: Vector2 = vector_move.toward_direction
	
	# 获取动画播放器
	var animation: AnimationPlayer = c_texture.animation_player
	
	# TODO: 根据朝向播放对应的待机动画
	# 例如：播放面向不同方向的待机动画
	if animation:
		# animation.play("idle_" + get_direction_string(direction))
		pass
	
	print("玩家状态: 进入空闲状态")

## 状态更新（重写方法）
## 
## 持续监听移动输入，当检测到移动时切换到移动状态。
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	var move_vector = vector_move.move_vector as Vector2
	
	# 检测是否有移动输入
	if not move_vector.is_zero_approx():
		# 尝试切换到移动状态
		var move_state = get_transition_state("move")
		if move_state:
			state_transition.emit(move_state)

## 退出空闲状态（重写方法）
## 
## 清理空闲状态相关设置。
func _exit():
	print("玩家状态: 退出空闲状态")

## 根据方向向量获取方向字符串（辅助方法）
## 
## 将方向向量转换为可用于动画名称的方向字符串。
## [param direction]: 方向向量，类型为 [Vector2]
## [br][br][b]返回:[/b] [String] 方向字符串（如"up", "down", "left", "right"）
func get_direction_string(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y > 0 else "up"
