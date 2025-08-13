## @editing: Sora [br]
## @describe: 传送交互 - 实现实体在不同场景间的传送功能
## 
## 该交互实现了场景传送系统，当实体触发传送交互时，
## 会立即传送到指定的目标位置和场景。支持跨楼层传送和精确定位。
## 
## 传送系统特性：
## - 即时传送：触发后立即执行传送操作
## - 跨场景支持：可以传送到不同的游戏场景或楼层
## - 精确定位：可以指定传送后的精确位置
## - 事件通知：传送完成后发出楼层变化事件
## - 实体兼容：支持任何类型的实体传送
## 
## 工作流程：
## 1. 实体触发传送交互
## 2. 获取目标传送位置
## 3. 立即更新实体的世界坐标
## 4. 发出楼层变化事件通知系统
## 5. 地图系统处理场景切换逻辑
## 
## 应用场景：
## - 楼梯传送：在不同楼层间移动
## - 传送门：快速旅行到远程位置
## - 房屋进出：进入建筑物内部场景
## - 地铁系统：快速交通网络
## - 魔法传送：通过魔法阵进行传送
class_name InteractionTransport
extends PassiveInteraction

## 目标楼层
## 传送的目标场景或楼层
@export var target_level: Level

## 目标传送点
## 传送后实体的具体位置，通过目标实体的初始化数据获取坐标
@export var target_point: IEntity

## 交互激活处理
## 当传送交互被触发时执行传送操作
## @param target_entity: 要进行传送的实体（通常是玩家）
func _on_interact_activated(target_entity: IEntity):
	# 验证传送目标的有效性
	if not target_point or not target_level:
		push_error("传送交互: 传送目标或楼层配置无效")
		return
	
	# 获取目标传送位置
	var transport_position = target_point.init_data_variant.get("transported_position") as Vector2
	if transport_position == Vector2.ZERO:
		push_warning("传送交互: 未找到有效的传送位置，使用目标点位置")
		transport_position = target_point.global_position
	
	# 执行传送：立即更新实体位置
	target_entity.main_control.global_position = transport_position
	
	# 发出楼层变化事件，通知地图系统处理场景切换
	SMapData.level_changed.emit(target_entity, target_level)
	
	var level_name = "未知楼层"
	if target_level:
		level_name = target_level.name
	print("传送交互: 实体传送完成 -> ", target_entity.name, " 传送到 -> ", level_name)

## 交互取消激活处理
## 当传送交互被取消时的处理（传送交互通常不需要取消处理）
func _on_interact_deactivated():
	# 传送是即时操作，通常不需要取消处理
	pass

## 获取传送目标信息
## @return: 包含目标楼层和位置信息的字典
func get_transport_info() -> Dictionary:
	var transport_position = Vector2.ZERO
	if target_point:
		transport_position = target_point.init_data_variant.get("transported_position")
	
	var point_name = "未知"
	if target_point:
		point_name = target_point.name
	
	return {
		"target_level": target_level,
		"target_position": transport_position,
		"target_point_name": point_name
	}

## 验证传送配置
## @return: 传送配置是否有效
func is_transport_valid() -> bool:
	return target_level != null and target_point != null
