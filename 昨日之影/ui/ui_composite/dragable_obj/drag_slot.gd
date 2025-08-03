extends PanelContainer

func _get_drag_data(at_position: Vector2) -> Variant:
	if get_child_count() == 1 and get_child(0) is DragableItem:
		var origin_dragable = get_child(0) as DragableItem
		var texture = origin_dragable.duplicate() as DragableItem
		var container = CenterContainer.new()
		container.use_top_left = true
		container.add_child(texture)
		set_drag_preview(container)
		return origin_dragable
	return false

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is DragableItem

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data :
		var pre_data = data.duplicate() as DragableItem
		pre_data.binding_item = data.binding_item
		if !(get_child_count() == 1 and get_child(0) is DragableItem):
			add_child(pre_data)
			data.queue_free()
		else: ## 尝试合成
			var pro_data: DragableItem = get_child(0)
			var item_fusion = SSubSystemManager.sub_systems.get(&"item_fusion") as SSItemFusion
			var fusion_record = item_fusion.fusion_up(pre_data.binding_item.item_nick_name,pro_data.binding_item.item_nick_name)
			if fusion_record is Item:
				pro_data.binding_item = fusion_record
				data.queue_free()
			pre_data.queue_free()
