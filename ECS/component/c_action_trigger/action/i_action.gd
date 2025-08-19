## 实体行为基类 - 定义实体可执行行为的抽象接口
## 该抽象类为所有实体行为提供统一的框架，行为需要与行为组件绑定使用
## 通过实现类来定义具体的行为逻辑，如死亡掉落、技能释放、状态变化等
## 行为分类：触发行为、持续行为、条件行为、组合行为
## 设计特性：与行为组件集成、可变参数支持、抽象方法约束、便捷执行接口
## 应用场景：实体死亡掉落、技能释放效果、状态变化响应、环境交互、AI决策
## 架构设计：继承自 [Node2D] 基类，使用 [annotation @abstract] 标记抽象类
## [br][b]编辑者:[/b] Sora
@abstract class_name IAction
extends Node2D

## 绑定的行为组件
## 指向拥有此行为的行为组件实例，用于访问实体信息，类型为 [IComponent]
var c_action: CActionTrigger

## 当前行为状态
## 当前行为状态，用于标识行为，比如"on_floor"
var current_action_state: StringName = &""

## 初始化行为的state信息
@abstract func _initialize()