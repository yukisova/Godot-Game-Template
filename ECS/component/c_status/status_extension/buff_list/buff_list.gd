## @editing: Sora [br]
## @describe: Buff列表扩展 - 管理实体的临时效果和状态修改器
## 
## 该扩展实现了Buff/Debuff系统，用于管理实体的临时状态效果，
## 如增强、减弱、状态异常、技能效果等。支持时效性和层叠效果。
## 
## Buff系统特性：
## - 时效性管理：自动处理Buff的持续时间和到期清理
## - 层叠效果：支持同类Buff的层叠和替换逻辑
## - 效果分类：增益、减益、特殊状态等不同类型
## - 动态修改：实时修改实体的属性和行为
## 
## 应用场景：
## - 魔法效果：加速、治疗、保护等
## - 状态异常：中毒、眩晕、冰冻等
## - 装备加成：武器、护甲的属性加成
## - 技能效果：技能释放产生的临时效果
## 
## @filename: buff_list.gd
class_name BuffListExtension
extends StatusExtension

## 当前激活的Buff字典
## 键为Buff ID，值为Buff数据（包含效果、持续时间、层数等）
var current_buff: Dictionary

## Buff添加信号
## @param buff_id: Buff标识符
## @param buff_data: Buff数据
signal buff_added(buff_id: String, buff_data: Dictionary)

## Buff移除信号
## @param buff_id: Buff标识符
signal buff_removed(buff_id: String)

## Buff更新信号
## @param buff_id: Buff标识符
## @param buff_data: 更新后的Buff数据
signal buff_updated(buff_id: String, buff_data: Dictionary)

## 扩展初始化
## 设置扩展类型并初始化Buff容器
func _initialize():
	extention_type = ExtensionType.临时效果
	current_buff.clear()

## 扩展效果执行
## 每帧更新所有激活Buff的持续时间，并处理到期的Buff
func _effect():
	var buffs_to_remove = []
	
	# 遍历所有激活的Buff
	for buff_id in current_buff.keys():
		var buff_data = current_buff[buff_id]
		
		# 更新持续时间
		if buff_data.has("duration") and buff_data.duration > 0:
			buff_data.duration -= get_process_delta_time()
			
			# 检查是否到期
			if buff_data.duration <= 0:
				buffs_to_remove.append(buff_id)
			else:
				# 触发Buff更新效果
				_apply_buff_effect(buff_id, buff_data)
				buff_updated.emit(buff_id, buff_data)
	
	# 移除到期的Buff
	for buff_id in buffs_to_remove:
		remove_buff(buff_id)

## 添加Buff
## @param buff_id: Buff唯一标识符
## @param duration: 持续时间（秒），-1表示永久
## @param intensity: 效果强度
## @param stack_type: 层叠类型（replace替换, stack层叠, extend延长）
func add_buff(buff_id: String, duration: float = -1, intensity: float = 1.0, stack_type: String = "replace"):
	var buff_data = {
		"duration": duration,
		"intensity": intensity,
		"start_time": Time.get_ticks_msec() / 1000.0
	}
	
	# 处理已存在的同类Buff
	if current_buff.has(buff_id):
		match stack_type:
			"replace":
				# 替换模式：覆盖原有Buff
				current_buff[buff_id] = buff_data
			"stack":
				# 层叠模式：增加强度
				current_buff[buff_id].intensity += intensity
				if duration > 0:
					current_buff[buff_id].duration = max(current_buff[buff_id].duration, duration)
			"extend":
				# 延长模式：延长持续时间
				if duration > 0:
					current_buff[buff_id].duration += duration
				current_buff[buff_id].intensity = max(current_buff[buff_id].intensity, intensity)
	else:
		# 新Buff直接添加
		current_buff[buff_id] = buff_data
	
	# 应用Buff效果
	_apply_buff_effect(buff_id, current_buff[buff_id])
	buff_added.emit(buff_id, current_buff[buff_id])

## 移除Buff
## @param buff_id: 要移除的Buff标识符
func remove_buff(buff_id: String):
	if current_buff.has(buff_id):
		# 移除Buff效果
		_remove_buff_effect(buff_id, current_buff[buff_id])
		current_buff.erase(buff_id)
		buff_removed.emit(buff_id)

## 检查Buff是否存在
## @param buff_id: Buff标识符
## @return: 是否存在
func has_buff(buff_id: String) -> bool:
	return current_buff.has(buff_id)

## 获取Buff数据
## @param buff_id: Buff标识符
## @return: Buff数据字典，如果不存在返回空字典
func get_buff(buff_id: String) -> Dictionary:
	return current_buff.get(buff_id, {})

## 清除所有Buff
func clear_all_buffs():
	for buff_id in current_buff.keys():
		remove_buff(buff_id)

## 应用Buff效果（子类可重写）
## @param buff_id: Buff标识符
## @param buff_data: Buff数据
func _apply_buff_effect(_buff_id: String, _buff_data: Dictionary):
	# 基类默认无效果，子类应该重写此方法实现具体的Buff效果
	pass

## 移除Buff效果（子类可重写）
## @param buff_id: Buff标识符
## @param buff_data: Buff数据
func _remove_buff_effect(_buff_id: String, _buff_data: Dictionary):
	# 基类默认无效果，子类应该重写此方法实现Buff移除时的清理
	pass

## 获取自定义存档数据
## @return: Buff列表的存档数据
func _get_custom_save_data() -> Dictionary:
	return {"current_buff": current_buff}

## 设置自定义存档数据
## @param data: 存档数据
func _set_custom_save_data(data: Dictionary):
	if data.has("current_buff"):
		current_buff = data.current_buff
