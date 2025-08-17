## 玩家移动状态 - 玩家角色移动时的状态实现
##
## 该状态负责处理玩家的移动行为和相应的动画播放。
## 当玩家输入移动指令时进入此状态，停止移动时自动切换回空闲状态。
##
## 状态特性：
## - 播放移动动画
## - 处理移动输入
## - 根据移动方向调整角色朝向
## - 监听移动停止条件
##
## 状态转换条件：
## - 移动向量为零 → 切换到空闲状态
## - 触发交互 → 切换到交互状态
## - 进入战斗 → 切换到战斗状态
##
## 应用场景：
## - 玩家角色移动时
## - 移动动画播放期间
## - 持续移动输入检测
##
## 架构设计：
## - 继承自 [StateHfsm] 基类
## - 使用 [annotation @tool] 支持编辑器预览
## - 与 [IUpdateAction] 组件集成
## - 通过 [CTextureController] 控制动画播放
##
## [br][b]编辑者:[/b] Sora
@tool
extends StateHfsm

## 移动策略组件
## 
## 用于获取移动向量和方向信息，类型为 [IUpdateAction]。
@export var vector_move: IUpdateAction

## 纹理组件
## 
## 用于播放移动动画和控制角色视觉表现，类型为 [CTextureController]。
@export var c_texture: CTextureController

## 进入移动状态（重写方法）
## 
## 初始化移动状态，开始播放移动动画。
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
