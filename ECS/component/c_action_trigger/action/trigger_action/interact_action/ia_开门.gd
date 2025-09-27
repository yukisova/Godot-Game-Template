@tool
extends ITriggerAction

@export var binding_collision: CollisionShape2D
@export var has_lock: bool = false:
	set(v):
		has_lock = v
		notify_property_list_changed()
		
@export_group("门在有锁的情况下的设置")
## 锁对应的钥匙的item_nick_name
@export var lock_key_nick_name: String = ""

func _trigger_update(..._args):
	var target_entity: IEntity = _args[0]
	if not check_unlock(target_entity):
		print("没有钥匙")
		return
	print("开门")
	
	binding_collision.disabled = true
	await get_tree().create_timer(3).timeout
	action_triggered_finished.emit()

func _trigger_update_finish():
	var flag: bool = true
	while flag:
		var space_state = binding_collision.get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = binding_collision.shape
		query.transform = binding_collision.get_global_transform()
		query.collision_mask = Main.PhysicsLayer.Wall
		query.exclude = [binding_collision.get_parent().get_rid()]
		var results = space_state.intersect_shape(query)
		if results.size() > 0:
			print("尝试自动关门时发现范围内存在其他碰撞体")
			await get_tree().create_timer(2.0).timeout
		else:
			flag = false
			
	print("关门")
	binding_collision.disabled = false

func _initialize():
	pass

func check_unlock(target_entity: IEntity):
	if has_lock:
		print("这扇门有钥匙，需要检查相关的钥匙")
		var c_status_list: CStatusList = target_entity.get_other_component(IComponent.ComponentName.C_STATUS_LIST)
		if c_status_list:
			var inventory: InventoryExtension = c_status_list.get_status_extension(StatusExtension.ExtensionType.INVENTORY)
			if inventory:
				if inventory.remove_consumable_by_nick_name(lock_key_nick_name):
					print("门已经解锁")
					has_lock = false
					return true
				else:
					return false
	else:
		return true

func _validate_property(property: Dictionary) -> void:
	if !has_lock:
		if property.name == "lock_key_nick_name":
			property.usage = PROPERTY_USAGE_NO_EDITOR
