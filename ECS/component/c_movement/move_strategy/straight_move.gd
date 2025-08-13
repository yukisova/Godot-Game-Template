## @editing: Sora [br]
## @describe: 直线飞行策略 - 实现高速直线移动的移动策略
## 
## 该策略专为需要高速直线移动的实体设计，如子弹、飞行道具、魔法效果等。
## 具有自动销毁机制，当到达目标位置或超时时会自动删除实体。
## 
## 移动特性：
## - 高速直线移动
## - 基于目标位置的自动导航
## - 超时自动销毁机制
## - 到达目标自动销毁
## 
## 适用场景：
## - 子弹飞行
## - 投掷物移动
## - 魔法弹道
## - 临时特效对象
class_name MoveStrategyStraight
extends MoveStrategy

## 移动方向向量
## 从黑板获取的初始移动方向，保持不变直到销毁
var direction: Vector2

## 策略检查和初始化
## 验证实体类型，设置自动销毁定时器，并从黑板获取移动参数
func _check_and_init():
	# 验证实体类型兼容性
	if binding_entity.main_control is not CharacterBody2D:
		push_error("直线飞行策略: 只适用于CharacterBody2D类型的实体")
		return
	
	# 设置2秒超时自动销毁机制
	get_tree().create_timer(2.0).timeout.connect(func():
		if is_instance_valid(binding_entity):
			binding_entity.queue_free()
	)
	
	# 从黑板获取初始移动方向
	direction = blackboard.get_value("start_direction", Vector2.RIGHT)

## 移动逻辑更新
## 执行高速直线移动，检查是否到达目标位置
## @param _delta: 帧时间间隔
func _update(_delta: float):
	# 应用高速直线移动
	binding_entity.main_control.velocity = direction * 5000 * _delta
	var current_pos = binding_entity.main_control.global_position
	
	# 检查是否到达目标位置
	var target_pos = blackboard.get_value("target_position", Vector2.ZERO)
	if current_pos.distance_to(target_pos) < 10:
		binding_entity.queue_free()
		return
	
	# 应用物理移动
	binding_entity.main_control.move_and_slide()

## 保存策略状态
## 直线飞行策略通常为临时对象，不需要存档
## @return: 空字典，表示不保存状态
func _save_as() -> Dictionary:
	# 直线飞行策略通常用于临时对象（如子弹），不需要存档
	return {}
