## 开启与关闭某一个物品的逻辑
## 门: disable指定的碰撞体
@tool
extends ITriggerAction

@export var exclude: Array[Area2D]

@export var binding_collision: CollisionShape2D
@export var binding_sprite: Sprite2D
@export var has_lock: bool = false:
	set(v):
		has_lock = v
		notify_property_list_changed()
		
@export_group("门在有锁的情况下的设置")
## 锁对应的钥匙的item_nick_name
@export var lock_key_nick_name: String = ""

func _trigger_update(..._args) -> bool:
	var target_entity: IEntity = _args[0]
	if check_collision(): return false
	is_running = true
	if not check_unlock(target_entity):
		is_running = false
		print("没有钥匙")
		return false
	print("开门")
	is_running = false
	binding_sprite.visible = false
	binding_collision.disabled = true
	return true

func _trigger_update_finish():
	while check_collision():
		await get_tree().create_timer(2).timeout
		
	print("关门")
	binding_sprite.visible = true
	binding_collision.disabled = false

func _exit_tree() -> void:
	pass

func _initialize():
	pass

func check_collision():
	var space_state = binding_collision.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = binding_collision.shape
	query.transform = binding_collision.get_global_transform()
	query.collision_mask = Main.PhysicsLayer.Wall
	var array = [binding_collision.get_parent().get_rid()]
	array.append_array(exclude.map(func(v): return v.get_rid()))
	query.exclude = array
	var results = space_state.intersect_shape(query)
	return not results.is_empty()

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
