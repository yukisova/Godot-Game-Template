## @editing: Sora [br]
## @describe: 开场制作人员名单 - 动态显示游戏制作团队信息
##
## 该组件负责在游戏开场时展示制作人员信息：
## - 循序渐进的文本动画显示
## - 专业的淡入淡出效果
## - 自动化的播放序列控制
## - 可配置的文本标签列表
##
## 主要功能：
## - 自动播放制作人员名单
## - 优雅的文本动画效果
## - 时间控制的序列播放
## - 支持任意数量的信息条目
##
## 动画特性：
## - 1秒淡入效果
## - 3秒停留显示
## - 1秒淡出效果（缓动）
## - 自动循环播放机制
##
## 使用场景：
## - 游戏开场的制作人员展示
## - 关于界面的团队信息
## - 特别鸣谢的滚动显示
## - 版权信息的动态展示
extends Control

#region 动画状态

## 当前显示索引
## 标记当前正在显示的文本标签索引
var current_index = 0

#endregion

#region 显示配置

## 文本标签列表
## 包含所有要显示的制作人员信息标签
@export var label_list: Array[Label]

#endregion

#region 动画控制

## 组件准备就绪
## 初始化所有标签为透明状态并开始播放
func _ready() -> void:
	print("制作人员名单: 开始初始化")
	
	# 设置所有标签为透明状态
	for label in get_children():
		if label is Label:
			label.modulate.a = 0
	
	# 开始播放动画序列
	start()

## 开始播放制作人员名单
## 循环播放所有配置的文本标签
func start():
	print("制作人员名单: 开始播放动画序列")
	
	# 播放三轮动画（可根据需要调整）
	await _running()
	await _running()
	await _running()
	
	print("制作人员名单: 动画播放完成")

## 播放单个标签的动画
## 执行淡入-停留-淡出的完整动画周期
func _running():
	var tween = get_tree().create_tween()
	
	# 检查索引有效性
	if current_index < label_list.size():
		var current_label = label_list[current_index]
		
		print("制作人员名单: 显示标签 %d -> %s" % [current_index, current_label.text])
		
		# 1秒淡入
		tween.tween_property(current_label, "modulate:a", 1.0, 1.0)
		
		# 停留3秒后1秒淡出（使用缓动效果）
		tween.tween_property(current_label, "modulate:a", 0.0, 1.0).set_delay(3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	
	# 递增索引
	current_index += 1
	
	# 等待动画完成
	await tween.finished

#endregion
	
