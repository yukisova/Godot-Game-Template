## 成为伙伴交互 - 将目标角色招募为玩家的同伴
##
## 该交互通常由对话系统辅助触发，将目标角色转换为玩家的同伴并加入队伍。
## 支持指定需要复制的组件，实现灵活的伙伴创建逻辑。
##
## 核心功能：
## - 基于场景的伙伴实例化
## - 选择性组件复制和传递
## - 伙伴位置和状态初始化
## - 与主控制器的队伍系统集成
##
## 工作流程：
## 1. 实例化伙伴场景
## 2. 复制指定的组件到新伙伴
## 3. 将伙伴添加到当前地图层级
## 4. 设置伙伴的初始位置
## 5. 通知主控制器伙伴加入
## 6. 销毁原始的招募目标实体
##
## 主要特性：
## - 动态的组件复制机制
## - 无缝的队伍管理集成
## - 自动的位置和状态同步
## - 完整的生命周期管理
##
## 使用场景：
## - NPC招募为队友
## - 剧情角色加入队伍
## - 临时伙伴的创建
## - 特殊角色的转换
##
## 架构设计：
## - 继承自 [Interaction] 基类
## - 使用 [PackedScene] 进行伙伴实例化
## - 基于 [Array] of [IComponent] 的组件复制
## - 与 [SMainController] 和 [SMapData] 集成
##
## [br][b]编辑者:[/b] Sora
extends Interaction

## 伙伴场景
## 
## 用于实例化伙伴的场景资源，类型为 [PackedScene]。
@export var partner_scene: PackedScene

## 伙伴组件复制列表
## 
## 需要从原实体复制到新伙伴的组件列表，类型为 [Array] of [IComponent]。
@export var partner_copy_list: Array[IComponent]

## 交互激活处理（重写方法）
## 
## 创建伙伴实体并执行招募流程。
## [param _interactor]: 触发交互的实体，类型为 [IEntity]
func _on_interact_activated(_interactor: IEntity):
	var partner: IEntity = partner_scene.instantiate()
	for i in partner_copy_list:
		var duplicate_component = i.duplicate()
		partner.component_container.add_child(duplicate_component)
	
	SMapData.current_level.add_child(partner)
	partner.global_position = binding_entity.global_position
	partner.main_control.global_position = binding_entity.main_control.global_position
	
	SMainController.partner_joined.emit(partner)
	
	binding_entity.queue_free()
	

## 交互取消激活处理（重写方法）
## 
## 成为伙伴交互通常不需要取消处理。
func _on_interact_deactivated():
	pass
