## 拾取交互 - 实现物品自动收集和拾取功能
## 该交互实现了完整的物品拾取系统，当玩家接触可拾取的物品时，会自动将物品添加到玩家的背包中
## 核心功能：自动拾取、背包集成、容量检查、错误处理、实体验证
## 拾取系统特性：物品完整性验证、组件可用性检查、智能的背包空间管理
## 工作流程：实体触发拾取→验证绑定物品→检查状态组件→获取背包扩展组件→添加到背包→处理结果反馈
## 应用场景：掉落物拾取、资源收集、任务物品、消耗品获取、装备获取
## 架构设计：继承自Interaction基类，与Item物品系统的深度集成，基于CStatusList和InventoryExtension的背包管理
## [br][b]编辑者:[/b] Sora
class_name InteractionCollect
extends IInteraction

## 绑定的物品
## 这个交互对象所代表的可拾取物品
@export var binding_item: Item

## 交互激活处理—当拾取交互被触发时尝试将物品添加到目标实体的背包
## [param _target_entity]: 触发拾取的实体（通常是玩家）
func __interact_begin(_target_entity: IEntity):
	# 验证物品是否有效
	if not binding_item:
		push_error("拾取交互: 未配置绑定物品")
		return
	
	# 获取目标实体的状态组件
	var status_component: CStatusList = _target_entity.get_other_component(IComponent.ComponentName.C_STATUS_LIST)
	if status_component == null:
		push_warning("拾取交互: 目标实体没有状态组件，无法拾取物品")
		return
	
	# 获取背包扩展组件
	var inventory_extension: InventoryExtension = status_component.status_extension.get(StatusExtension.ExtensionType.INVENTORY)
	if inventory_extension == null:
		push_warning("拾取交互: 目标实体没有背包系统，无法存储物品")
		return
	
	# 尝试添加物品到背包
	var success = inventory_extension.auto_add_inventory(binding_item.duplicate(true))
	
	if success:
		print("拾取交互: 成功拾取物品 -> ", binding_item.item_name)
		# TODO: 播放拾取音效和特效
		# TODO: 显示拾取提示UI
		
		# 拾取成功后可以销毁这个拾取对象
		_handle_successful_pickup()
	else:
		print("拾取交互: 拾取失败，可能是背包已满 -> ", binding_item.item_name)
		# TODO: 显示背包已满的提示

func __interact_reset() -> void: pass

## 处理成功拾取后的逻辑—可以在这里添加拾取成功后的特效、音效或对象销毁逻辑
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

## 获取物品信息—获取当前绑定的物品信息
func get_item_info() -> Item:
	return binding_item

## 检查是否可以拾取—检查指定实体是否可以拾取当前物品
## [param target_entity]: 目标实体
func can_pickup(target_entity: IEntity) -> bool:
	if not binding_item:
		return false
	
	var status_component: CStatusList = target_entity.get_other_component(IComponent.ComponentName.C_STATUS_LIST)
	if not status_component:
		return false
	
	var inventory_extension: InventoryExtension = status_component.status_extension.get(StatusExtension.ExtensionType.INVENTORY)
	if not inventory_extension:
		return false
	
	return not inventory_extension.is_inventory_full()
