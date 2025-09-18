## 玩家属性HUD视图 - MVC架构中的View层
## 负责UI元素的显示和更新，不包含业务逻辑
## 提供清晰的UI更新接口，支持数据驱动的界面更新
## 继承自CanvasLayer以保持与原有UI系统的兼容性
## [br][b]编辑者:[/b] Sora
class_name AttributeHudView
extends CanvasLayer

# UI组件引用
@export var health_bar: ProgressBar
@export var sound_bar: ProgressBar  
@export var fitness_bar: ProgressBar
@export var left_hand_texture: TextureRect
@export var right_hand_texture: TextureRect

# 用户交互信号（如果需要的话）
## 用户点击血量条信号（预留）
# signal health_bar_clicked()

## 用户点击体力条信号（预留）
# signal fitness_bar_clicked()

## 验证UI组件是否正确配置
func _ready() -> void:
	_validate_ui_components()

## 验证所有必需的UI组件是否已正确配置
func _validate_ui_components() -> void:
	var missing_components: Array[String] = []
	
	if !health_bar:
		missing_components.append("health_bar")
	if !fitness_bar:
		missing_components.append("fitness_bar")
	if !left_hand_texture:
		missing_components.append("left_hand_texture")
	if !right_hand_texture:
		missing_components.append("right_hand_texture")
		
	if missing_components.size() > 0:
		push_error("AttributeHudView: 缺少UI组件配置: %s" % str(missing_components))

## 更新血量显示
## [param current_value]: 当前血量值
## [param max_value]: 最大血量值
func update_health(current_value: float, max_value: float) -> void:
	if !health_bar:
		push_warning("AttributeHudView: health_bar未配置，无法更新血量显示")
		return
		
	health_bar.max_value = max_value
	health_bar.value = current_value
	
	# 可以在这里添加视觉效果，比如血量过低时闪烁
	_apply_health_visual_effects(current_value, max_value)

## 更新体力显示  
## [param current_value]: 当前体力值
## [param max_value]: 最大体力值
func update_fitness(current_value: float, max_value: float) -> void:
	if !fitness_bar:
		push_warning("AttributeHudView: fitness_bar未配置，无法更新体力显示")
		return
		
	fitness_bar.max_value = max_value
	fitness_bar.value = current_value
	
	# 可以在这里添加视觉效果，比如体力过低时变色
	_apply_fitness_visual_effects(current_value, max_value)

## 更新武器显示（左手）
## [param weapon_texture]: 武器贴图，null表示无武器
func update_weapon(weapon_texture: Texture2D) -> void:
	if !left_hand_texture:
		push_warning("AttributeHudView: left_hand_texture未配置，无法更新武器显示")
		return
		
	left_hand_texture.texture = weapon_texture
	
	# 可以添加武器切换的动画效果
	_apply_weapon_change_effect()

## 更新装备显示（右手）
## [param equipment_texture]: 装备贴图，null表示无装备
func update_equipment(equipment_texture: Texture2D) -> void:
	if !right_hand_texture:
		push_warning("AttributeHudView: right_hand_texture未配置，无法更新装备显示")
		return
		
	right_hand_texture.texture = equipment_texture
	
	# 可以添加装备切换的动画效果  
	_apply_equipment_change_effect()

## 初始化所有UI元素的显示状态
## [param health_current]: 初始血量
## [param health_max]: 最大血量
## [param fitness_current]: 初始体力  
## [param fitness_max]: 最大体力
## [param weapon_tex]: 初始武器贴图
## [param equipment_tex]: 初始装备贴图
func initialize_display(
	health_current: float, health_max: float,
	fitness_current: float, fitness_max: float, 
	weapon_tex: Texture2D = null, equipment_tex: Texture2D = null
) -> void:
	update_health(health_current, health_max)
	update_fitness(fitness_current, fitness_max)
	update_weapon(weapon_tex)
	update_equipment(equipment_tex)

## 显示视图
func show_view() -> void:
	visible = true

## 隐藏视图
func hide_view() -> void:
	visible = false

## 设置视图的透明度
## [param alpha]: 透明度值 (0.0-1.0)
func set_view_alpha(alpha: float) -> void:
	# CanvasLayer使用layer透明度控制
	layer = int(clamp(alpha * 100, 0, 100))
	# 或者控制子节点的modulate
	for child in get_children():
		if child.has_method("set_modulate"):
			child.modulate.a = clamp(alpha, 0.0, 1.0)

# 私有方法 - 视觉效果处理

## 应用血量相关的视觉效果
func _apply_health_visual_effects(current_value: float, max_value: float) -> void:
	if !health_bar:
		return
		
	var health_ratio = current_value / max_value if max_value > 0 else 0.0
	
	# 血量过低时变红色警告
	if health_ratio <= 0.2:
		health_bar.modulate = Color.RED
		# 可以添加闪烁动画
		_create_low_health_flash_animation()
	elif health_ratio <= 0.5:
		health_bar.modulate = Color.YELLOW  
	else:
		health_bar.modulate = Color.WHITE

## 应用体力相关的视觉效果
func _apply_fitness_visual_effects(current_value: float, max_value: float) -> void:
	if !fitness_bar:
		return
		
	var fitness_ratio = current_value / max_value if max_value > 0 else 0.0
	
	# 体力过低时变橙色提醒
	if fitness_ratio <= 0.2:
		fitness_bar.modulate = Color.ORANGE
	elif fitness_ratio <= 0.5:
		fitness_bar.modulate = Color.YELLOW
	else:
		fitness_bar.modulate = Color.WHITE

## 应用武器切换效果
func _apply_weapon_change_effect() -> void:
	if !left_hand_texture:
		return
		
	# 简单的缩放动画效果
	var tween = create_tween()
	left_hand_texture.scale = Vector2(0.8, 0.8)
	tween.tween_property(left_hand_texture, "scale", Vector2(1.0, 1.0), 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

## 应用装备切换效果
func _apply_equipment_change_effect() -> void:
	if !right_hand_texture:
		return
		
	# 简单的缩放动画效果
	var tween = create_tween()
	right_hand_texture.scale = Vector2(0.8, 0.8)
	tween.tween_property(right_hand_texture, "scale", Vector2(1.0, 1.0), 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

## 创建血量过低闪烁动画
func _create_low_health_flash_animation() -> void:
	if !health_bar:
		return
		
	# 避免重复创建动画
	if health_bar.has_meta("flashing"):
		return
		
	health_bar.set_meta("flashing", true)
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(health_bar, "modulate:a", 0.5, 0.5)
	tween.tween_property(health_bar, "modulate:a", 1.0, 0.5)
	
	# 当血量恢复时停止闪烁
	tween.finished.connect(func(): health_bar.remove_meta("flashing"))

## 停止所有动画效果
func stop_all_animations() -> void:
	# 停止所有Tween动画
	get_tree().create_tween().kill()
	
	# 重置组件状态
	if health_bar:
		health_bar.modulate = Color.WHITE
		health_bar.remove_meta("flashing")
	if fitness_bar:
		fitness_bar.modulate = Color.WHITE
	if left_hand_texture:
		left_hand_texture.scale = Vector2.ONE
	if right_hand_texture:
		right_hand_texture.scale = Vector2.ONE

## 获取视图状态信息（用于调试）
func get_debug_info() -> Dictionary:
	return {
		"visible": visible,
		"layer": layer,
		"health_bar_configured": health_bar != null,
		"fitness_bar_configured": fitness_bar != null,
		"left_hand_configured": left_hand_texture != null,
		"right_hand_configured": right_hand_texture != null,
		"health_value": health_bar.value if health_bar else 0.0,
		"fitness_value": fitness_bar.value if fitness_bar else 0.0
	}
