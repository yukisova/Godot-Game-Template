## @editing: Sora [br]
## @describe: 指定Entity所可能出现的行为的具体逻辑，以模组的方式进行绑定，如死亡掉落。[br]
## 				潜力：可以定义玩家的一些特殊动作，并使用InputListener进行激活
@tool
class_name C_Action
extends IComponent

signal _action_searched ## FIXME 这里原本的目的是用于搜索已有的Action,但是Action往往是可以直接引用的, 这个信号目前似乎没有存在的必要

func _enter_tree() -> void:
	component_name = ComponentName.c_action

## 初始化: 将子节点下的Action类绑定自身, 方便获取实体信息
func _initialize(_owner: Entity):
	super(_owner)
	
	for i: Action in get_children():
		i.c_action = self
