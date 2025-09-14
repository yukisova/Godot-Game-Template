## 盒子射线基类 - RayCast2D射线检测的增强封装
## 提供统一的射线检测接口，用于视线检测、射击判定等
## 与CCollisionBox组件集成，支持子类逻辑扩展
## [br][b]编辑者:[/b] Sora
@abstract class_name BoxRay
extends RayCast2D

## 射线名称
## 射线的唯一标识符
var box_ray_name: CCollisionBox.BoxRayName

## 碰撞组件引用
## 关联的碰撞组件实例
var c_collision: CCollisionBox

## 启用朝向旋转
## 根据实体移动方向自动旋转
var enable_rotate_by_award: bool = false:
	set(v):
		# 只有拥有移动组件的实体才能启用朝向旋转
		if c_collision.get_other_component(IComponent.ComponentName.C_ACTION_TRIGGER):
			enable_rotate_by_award = v
		else:
			enable_rotate_by_award = false
			push_warning("盒子碰撞: 实体缺少移动组件，无法启用朝向旋转")

@abstract func _initialize()

## 每帧调用的射线状态更新
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	# 基类默认无特殊更新逻辑，子类可根据需要重写
	pass
