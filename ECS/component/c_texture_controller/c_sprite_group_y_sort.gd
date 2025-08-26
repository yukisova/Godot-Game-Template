## Sprite组Y排序组件 - 将节点下的所有Sprite2D视为统一整体进行Y排序
## 支持忽略内部z_index，将整个sprite组作为一个整体与其他sprite进行深度排序
## 主要用于角色、物品等由多个sprite组成的复杂对象
## [br][b]编辑者:[/b] Sora
@tool
class_name CSpriteGroupYSort
extends Node2D

## 排序参考点类型
enum SortReferenceType {
	CENTER, ## 使用组内所有sprite的中心点作为排序参考
	BOTTOM, ## 使用组内所有sprite的底部边界作为排序参考
	TOP,    ## 使用组内所有sprite的顶部边界作为排序参考
	CUSTOM  ## 使用自定义参考点
}

## 排序参考点类型
@export var sort_reference_type: SortReferenceType = SortReferenceType.CENTER

## 自定义参考点偏移量（相对于节点中心）
@export var custom_reference_offset: Vector2 = Vector2.ZERO

## 是否启用自动排序
@export var auto_sort_enabled: bool = true

## 排序更新频率（秒）
@export var sort_update_interval: float = 0.016 # 60fps

## 内部sprite节点列表
var internal_sprites: Array[Sprite2D] = []

## 排序参考点
var sort_reference_point: Vector2 = Vector2.ZERO

## 上次排序时间
var last_sort_time: float = 0.0

func _enter_tree() -> void:
	# 延迟初始化，确保节点树完全加载
	call_deferred("_initialize")

func _initialize():
	_collect_internal_sprites()
	_calculate_sort_reference_point()
	
	# 注册到sprite组y排序系统
	if has_node("/root/SSpriteGroupYSort"):
		var y_sort_system = get_node("/root/SSpriteGroupYSort")
		if y_sort_system.has_method("register_sprite_group"):
			y_sort_system.register_sprite_group(self)

## 收集节点下的所有Sprite2D
func _collect_internal_sprites() -> void:
	internal_sprites.clear()
	_collect_sprites_recursive(self)

## 递归收集Sprite2D节点
func _collect_sprites_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is Sprite2D:
			internal_sprites.append(child)
		_collect_sprites_recursive(child)

## 计算排序参考点
func _calculate_sort_reference_point() -> void:
	if internal_sprites.is_empty():
		sort_reference_point = global_position
		return
	
	match sort_reference_type:
		SortReferenceType.CENTER:
			_calculate_center_reference()
		SortReferenceType.BOTTOM:
			_calculate_bottom_reference()
		SortReferenceType.TOP:
			_calculate_top_reference()
		SortReferenceType.CUSTOM:
			_calculate_custom_reference()

## 计算中心点参考
func _calculate_center_reference() -> void:
	var total_position = Vector2.ZERO
	var count = 0
	
	for sprite in internal_sprites:
		total_position += sprite.global_position
		count += 1
	
	if count > 0:
		sort_reference_point = total_position / count
	else:
		sort_reference_point = global_position

## 计算底部边界参考
func _calculate_bottom_reference() -> void:
	var bottom_y = -INF
	
	for sprite in internal_sprites:
		var sprite_bottom = sprite.global_position.y
		if sprite.texture:
			sprite_bottom += sprite.texture.get_size().y * sprite.scale.y * 0.5
		bottom_y = max(bottom_y, sprite_bottom)
	
	sort_reference_point = Vector2(global_position.x, bottom_y)

## 计算顶部边界参考
func _calculate_top_reference() -> void:
	var top_y = INF
	
	for sprite in internal_sprites:
		var sprite_top = sprite.global_position.y
		if sprite.texture:
			sprite_top -= sprite.texture.get_size().y * sprite.scale.y * 0.5
		top_y = min(top_y, sprite_top)
	
	sort_reference_point = Vector2(global_position.x, top_y)

## 计算自定义参考点
func _calculate_custom_reference() -> void:
	sort_reference_point = global_position + custom_reference_offset

## 获取排序参考点的Y坐标
func get_sort_y() -> float:
	return sort_reference_point.y

## 更新排序参考点
func update_sort_reference() -> void:
	_calculate_sort_reference_point()

## 强制重新收集sprite并更新参考点
func refresh_sprites() -> void:
	_collect_internal_sprites()
	_calculate_sort_reference_point()

func _process(_delta: float) -> void:
	if !auto_sort_enabled:
		return
	
	last_sort_time += _delta
	if last_sort_time >= sort_update_interval:
		_calculate_sort_reference_point()
		last_sort_time = 0.0

## 当节点位置改变或被删除时的处理
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		_calculate_sort_reference_point()
	elif what == NOTIFICATION_PREDELETE:
		# 从sprite组y排序系统中注销
		if has_node("/root/SSpriteGroupYSort"):
			var y_sort_system = get_node("/root/SSpriteGroupYSort")
			if y_sort_system.has_method("unregister_sprite_group"):
				y_sort_system.unregister_sprite_group(self)
