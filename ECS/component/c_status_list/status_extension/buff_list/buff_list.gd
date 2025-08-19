## Buff列表扩展 - 管理实体的临时效果和状态修改器
## 实现完整的Buff/Debuff系统，支持时效管理和层叠效果
## 包括替换、层叠、延长三种模式和自动清理机制
## [br][b]编辑者:[/b] Sora
class_name BuffListExtension
extends StatusExtension

## 当前激活的Buff字典
## 存储所有激活的Buff数据
var current_buff: Dictionary

## Buff添加信号
## [param buff_id]: Buff标识符
## [param buff_data]: Buff数据字典
signal buff_added(buff_id: String, buff_data: Dictionary)

## Buff移除信号
## [param buff_id]: Buff标识符
signal buff_removed(buff_id: String)

## Buff更新信号
## [param buff_id]: Buff标识符
## [param buff_data]: 更新后的Buff数据字典
signal buff_updated(buff_id: String, buff_data: Dictionary)

## 设置扩展类型并初始化Buff容器
func _initialize():
	extention_type = ExtensionType.BUFF_LIST
	current_buff.clear()

## 每帧更新Buff持续时间并处理到期Buff
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

## 向实体添加Buff效果
## [param buff_id]: Buff唯一标识符
## [param duration]: 持续时间（秒），-1表示永久
## [param intensity]: 效果强度倍数
## [param stack_type]: 层叠类型
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

## 从实体移除指定Buff效果
## [param buff_id]: 要移除的Buff标识符
func remove_buff(buff_id: String):
	if current_buff.has(buff_id):
		# 移除Buff效果
		_remove_buff_effect(buff_id, current_buff[buff_id])
		current_buff.erase(buff_id)
		buff_removed.emit(buff_id)

## 判断指定Buff是否激活
## [param buff_id]: Buff标识符
func has_buff(buff_id: String) -> bool:
	return current_buff.has(buff_id)

## 获取指定Buff的详细数据
## [param buff_id]: Buff标识符
func get_buff(buff_id: String) -> Dictionary:
	return current_buff.get(buff_id, {})

## 移除实体身上的所有Buff效果
func clear_all_buffs():
	for buff_id in current_buff.keys():
		remove_buff(buff_id)

## 子类重写实现具体Buff效果应用
## [param _buff_id]: Buff标识符
## [param _buff_data]: Buff数据字典
func _apply_buff_effect(_buff_id: String, _buff_data: Dictionary):
	# 基类默认无效果，子类应该重写此方法实现具体的Buff效果
	pass

## 子类重写实现Buff移除时的清理逻辑
## [param _buff_id]: Buff标识符
## [param _buff_data]: Buff数据字典
func _remove_buff_effect(_buff_id: String, _buff_data: Dictionary):
	# 基类默认无效果，子类应该重写此方法实现Buff移除时的清理
	pass

#region 存档系统

## 保存当前所有激活的Buff状态
func _save() -> Dictionary:
	return {
		extention_type:{
			"current_buff": current_buff
		}
	}

## 从存档数据恢复Buff状态
## [param _data]: 存档数据字典
func _load(_data: Dictionary):
	current_buff = _data.get("current_buff", {})

#endregion
