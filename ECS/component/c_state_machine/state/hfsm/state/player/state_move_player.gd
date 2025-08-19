## 玩家移动状态 - 玩家角色移动时的状态实现
## 负责处理玩家的移动行为和相应的动画播放
## 状态特性：播放移动动画、处理移动输入、调整角色朝向、监听移动停止条件
## 状态转换：移动向量为零时切换到空闲状态，触发交互或进入战斗
## [br][b]编辑者:[/b] Sora
@tool
extends StateHfsm

## 移动策略组件，用于获取移动向量和方向信息
@export var vector_move: IUpdateAction

## 纹理组件，用于播放移动动画和控制角色视觉表现
@export var c_texture: CTextureController

## 进入移动状态，初始化移动状态，开始播放移动动画
func _enter():
	print("玩家状态: 进入移动状态")
	

## 状态更新（重写方法）
## 
## 监听移动向量，当移动停止时切换到空闲状态。
## [param _delta]: 帧时间间隔
func _update(_delta: float) -> void:
	var vector: Vector2 = vector_move.move_vector
	
	# 检查是否停止移动
	if vector.is_zero_approx():
		var idle_state = get_transition_state("idle")
		if idle_state:
			state_transition.emit(idle_state)

## 退出移动状态（重写方法）
## 
## 清理移动状态，停止移动动画。
func _exit():
	print("玩家状态: 退出移动状态")
