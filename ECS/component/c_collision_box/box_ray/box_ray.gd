## 盒子射线基类 - RayCast2D射线检测的增强封装
## 提供统一的射线检测接口，用于视线检测、射击判定等
## 与CCollisionBox组件集成，支持子类逻辑扩展
## [br][b]编辑者:[/b] Sora
class_name BoxRay
extends RayCast2D

## 射线名称
## 射线的唯一标识符
var box_ray_name: CCollisionBox.BoxRayName

## 碰撞组件引用
## 关联的碰撞组件实例
var c_collision: CCollisionBox

## 每帧调用的射线状态更新
## [param _delta]: 帧时间间隔
func _update(_delta: float):
	# 基类默认无特殊更新逻辑，子类可根据需要重写
	pass
