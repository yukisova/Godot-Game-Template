## @editing: Sora [br]
## @describe: 拾取交互 - 实现物品自动收集和拾取功能
## 
## 该交互实现了物品拾取系统，当玩家接触可拾取的物品时，
## 会自动将物品添加到玩家的背包中。支持背包容量检查和拾取反馈。
## 
## 拾取系统特性：
## - 自动拾取：无需玩家主动操作即可收集物品
## - 背包集成：直接与背包系统对接，自动寻找空位
## - 容量检查：自动检查背包是否有足够空间
## - 错误处理：优雅处理背包满等异常情况
## - 实体验证：确保目标实体具备必要的组件
## 
## 工作流程：
## 1. 实体触发拾取交互
## 2. 验证实体是否具有状态组件
## 3. 获取实体的背包扩展组件
## 4. 尝试将物品添加到背包
## 5. 处理添加结果和反馈
## 
## 应用场景：
## - 掉落物拾取：自动收集战利品和掉落物
## - 资源收集：收集游戏世界中的资源
## - 任务物品：收集特定的任务相关物品
## - 消耗品获取：拾取药水、食物等消耗品
## - 装备获取：拾取新的武器和装备
## 
## TODO: 未来可以增加拾取动画、音效和更丰富的反馈
class_name InteractionCollect
extends PassiveInteraction

## 绑定的物品
## 这个交互对象所代表的可拾取物品
@export var binding_item: Item

## 交互激活处理
## 当拾取交互被触发时尝试将物品添加到目标实体的背包
## @param _target_entity: 触发拾取的实体（通常是玩家）
func _on_interact_activated(_target_entity: IEntity):
	# 验证物品是否有效
	if not binding_item:
		push_error("拾取交互: 未配置绑定物品")
		return
	
	# 获取目标实体的状态组件
	var status_component: CStatus = _target_entity.list_base_components.get(IComponent.ComponentName.c_status)
	if status_component == null:
		push_warning("拾取交互: 目标实体没有状态组件，无法拾取物品")
		return
	
	# 获取背包扩展组件
	var inventory_extension: InventoryExtension = status_component.status_extension.get(StatusExtension.ExtensionType.INVENTORY)
	if inventory_extension == null:
		push_warning("拾取交互: 目标实体没有背包系统，无法存储物品")
		return
	
	# 尝试添加物品到背包
	var success = inventory_extension.auto_add_inventory(binding_item)
	
	if success:
		print("拾取交互: 成功拾取物品 -> ", binding_item.item_name)
		# TODO: 播放拾取音效和特效
		# TODO: 显示拾取提示UI
		
		# 拾取成功后可以销毁这个拾取对象
		_handle_successful_pickup()
	else:
		print("拾取交互: 拾取失败，可能是背包已满 -> ", binding_item.item_name)
		# TODO: 显示背包已满的提示

## 交互取消激活处理
## 拾取交互通常不需要取消处理
func _on_interact_deactivated():
	# 拾取是即时操作，通常不需要取消处理
	pass

## 处理成功拾取后的逻辑
## 可以在这里添加拾取成功后的特效、音效或对象销毁逻辑
func _handle_successful_pickup():
	# TODO: 播放拾取特效
	# TODO: 播放拾取音效
	# TODO: 可选择性地销毁拾取对象或隐藏它
	
	# 示例：延迟销毁拾取对象
	# get_tree().create_timer(0.5).timeout.connect(func(): 
	#     if binding_entity:
	#         binding_entity.queue_free()
	# )
	pass

## 获取物品信息
## @return: 绑定物品的信息，如果没有绑定物品则返回null
func get_item_info() -> Item:
	return binding_item

## 检查是否可以拾取
## @param target_entity: 目标实体
## @return: 是否可以进行拾取操作
func can_pickup(target_entity: IEntity) -> bool:
	if not binding_item:
		return false
	
	var status_component: CStatus = target_entity.list_base_components.get(IComponent.ComponentName.c_status)
	if not status_component:
		return false
	
	var inventory_extension: InventoryExtension = status_component.status_extension.get(StatusExtension.ExtensionType.INVENTORY)
	if not inventory_extension:
		return false
	
	return not inventory_extension.is_inventory_full()
