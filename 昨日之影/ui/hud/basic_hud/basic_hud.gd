##@editing:	Sora
##@describe:	角色的基础hud
extends IHud

var binding_entity: Entity

@export_group("时间循环", "time_")
@export var hour_pointer: Line2D
@export var minute_pointer: Line2D

@export_group("背包抽屉", "bag_")
@export var bag_button: Button
@export var bag_slot_container: HBoxContainer
@export var bag_slot_prototype: PanelContainer
@export var bag_dragable_item_prototype: DragableItem

var inventory_in_player: InventoryExtension


func _initialize():
	var timeloop = SSubSystemManager.sub_systems[&"time_loop"] as SSTimeLoop
	timeloop.time_updated.connect(func(v: int):
		rotate_pointer(v)
		)
	rotate_pointer(timeloop.real_time)
	
	bag_button.toggled.connect(func(v: bool):
		if v:
			drawer_on()
		else:
			drawer_off()
		)
	

	var player = SMainController.player_static
	var status_in_player = player.list_base_components[IComponent.ComponentName.c_status] as C_Status
	inventory_in_player = status_in_player.status_extension[StatusExtension.ExtensionType.背包] as InventoryExtension
	
	inventory_in_player.inventory_added.connect(_on_add_inventory)
	inventory_in_player.inventory_removed.connect(_on_remove_inventory)
	for i in inventory_in_player.inventory_pack_num:
		var bag_slot = bag_slot_prototype.duplicate() as PanelContainer
		bag_slot_container.add_child(bag_slot)
		bag_slot.show()
		
		var item = inventory_in_player.inventory_array[i] as Item
		if item != null:
			var bag_dragable_item = bag_dragable_item_prototype.duplicate() as DragableItem
			bag_slot.add_child(bag_dragable_item)
			bag_dragable_item.binding_item = item
			bag_dragable_item.texture_rect.texture = item.item_texture
			bag_dragable_item.origin_position = bag_slot.global_position
			bag_dragable_item.show()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	bag_slot_container.position = Vector2(-bag_slot_container.size.x,16)

func _refresh():
	pass


func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed and .get_global_rect().has_point(event.global_position):
			## 点击时开始拖拽
			#is_dragging = true
			#drag_offset = global_position - event.global_position
			#z_index = 100  # 置顶显示
			#_tween_selected()
		#else:
			#_tween_unselected()
			#is_dragging = false
	pass

func rotate_pointer(current_timer: int):

	var hour = current_timer / 60.0 / 24
	var minute = current_timer % 60 / 60.0
	
	var target_hour_rotation = hour * 2 * PI
	var target_min_rotation = minute * 2 * PI
	
	hour_pointer.rotation = target_hour_rotation
	minute_pointer.rotation = target_min_rotation
	

#region 抽屉式背包
func drawer_on():
	bag_button.button_mask ^= MOUSE_BUTTON_MASK_LEFT
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(bag_slot_container, "position", Vector2(0,16), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	bag_button.button_mask |= MOUSE_BUTTON_MASK_LEFT

func drawer_off():
	bag_button.button_mask ^= MOUSE_BUTTON_MASK_LEFT
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(bag_slot_container, "position", Vector2(-bag_slot_container.size.x,16), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	bag_button.button_mask |= MOUSE_BUTTON_MASK_LEFT

func _on_add_inventory(item: Item, index: int):
	var bag_dragable_item = bag_dragable_item_prototype.duplicate() as DragableItem
	var bag_slot = bag_slot_container.get_child(index)
	
	bag_slot.add_child(bag_dragable_item)
	bag_dragable_item.binding_item = item
	bag_dragable_item.texture = item.item_texture
	bag_dragable_item.origin_position = bag_slot.global_position
	bag_dragable_item.show()

func _on_remove_inventory(index: int):
	var target_bag_slot = bag_slot_container.get_child(index)
	target_bag_slot.get_children().map(func(v): return v.queue_free())

#endregion
