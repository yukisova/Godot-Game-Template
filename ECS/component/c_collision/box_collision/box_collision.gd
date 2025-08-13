## @editing: Sora [br]
## @describe: 盒子碰撞基类 - 为Area2D提供增强功能的碰撞体封装
## 
## 该抽象类为所有盒子碰撞体提供统一的基础功能和接口。
## 考虑到许多碰撞体需要额外的功能修饰而设计，提供了方向跟随等特性。
## 
## 功能特性：
## - 与碰撞组件集成
## - 支持根据移动方向自动旋转
## - 可扩展的碰撞体类型
## - 统一的生命周期管理
## 
## 派生类型：
## - InteractBox: 交互碰撞体
## - HurtBox: 伤害接收碰撞体
## - HitBox: 攻击判定碰撞体
## - SightBox: 视野检测碰撞体
## - SeekBox: 搜索检测碰撞体
@abstract class_name BoxCollision
extends Area2D

## 绑定的碰撞组件
## 指向拥有此碰撞体的碰撞组件实例
var c_collision: C_Collision

## 启用朝向旋转
## 当设置为true时，碰撞体会根据实体的移动方向自动旋转
var enable_rotate_by_award: bool = false:
	set(v):
		# 只有拥有移动组件的实体才能启用朝向旋转
		if c_collision.component_owner.list_base_components.has(IComponent.ComponentName.c_movement):
			enable_rotate_by_award = v
		else:
			enable_rotate_by_award = false
			push_warning("盒子碰撞: 实体缺少移动组件，无法启用朝向旋转")

func _update(_delta: float):
	pass
