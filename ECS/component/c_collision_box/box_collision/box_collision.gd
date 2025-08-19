## 盒子碰撞基类 - Area2D碰撞体的增强封装
## 为所有盒子碰撞体提供统一接口，支持方向跟随等特性
## 派生类型包括交互、伤害、攻击、视野、搜索等碰撞体
## [br][b]编辑者:[/b] Sora
@abstract class_name BoxCollision
extends Area2D

## 碰撞体名称
## 用于在CCollisionBox组件中索引
var box_collision_name: CCollisionBox.BoxCollisionName

## 绑定的碰撞组件
## 指向拥有此碰撞体的组件实例
var c_collision: CCollisionBox

## 启用朝向旋转
## 根据实体移动方向自动旋转
var enable_rotate_by_award: bool = false:
	set(v):
		# 只有拥有移动组件的实体才能启用朝向旋转
		if c_collision.component_owner.list_base_components.has(IComponent.ComponentName.C_ACTION_TRIGGER):
			enable_rotate_by_award = v
		else:
			enable_rotate_by_award = false
			push_warning("盒子碰撞: 实体缺少移动组件，无法启用朝向旋转")

## 每帧更新碰撞体状态
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	pass
