## 视线碰撞资源 - SightBox的配套视线生成配置
##
## 该资源类为 [SightBox] 提供视线碰撞检测的配置数据，
## 根据配置的视线类型和参数生成对应的碰撞检测区域。
##
## 核心功能：
## - 多种视线形状的支持
## - 灵活的视线参数配置
## - 与SightBox的无缝集成
## - 可视化的编辑器配置
##
## 视线类型：
## - [b]Sector[/b]：扇形视线（适用于大部分AI视觉）
## - [b]Capsule[/b]：胶囊形视线（适用于走廊等狭长区域）
## - [b]Rectangle[/b]：矩形视线（适用于巡逻和定向检测）
##
## 配置参数：
## - 视线宽度：控制视线的横向范围
## - 视线距离：控制视线的纵向范围
## - 位置偏移：调整视线相对于实体的位置
##
## 应用场景：
## - AI敌人的视线检测
## - 安全摄像头的监控范围
## - 触发器的检测区域
## - 灯光的照射范围
## - 传感器的感应区域
##
## 架构设计：
## - 继承自 [Resource] 基类
## - 基于枚举的视线类型管理
## - 支持Godot的资源序列化机制
## - 与SightBox组件的集成
##
## [br][b]编辑者:[/b] Sora
class_name BoxCollisionResource
extends Resource

## 视线碰撞类型枚举
##
## 定义支持的视线形状类型。
enum SightCollisionType{
	Sector,    ## 扇形视线
	Capsule,   ## 胶囊形视线
	Rectangle  ## 矩形视线
}

## 视线碰撞类型
## 
## 视线的形状类型，类型为 [enum SightCollisionType]。
@export var sight_collision_type: SightCollisionType

## 视线宽度
## 
## 视线的横向宽度范围。
@export var sight_wide: float = 2

## 视线距离
## 
## 视线的纵向检测距离。
@export var sight_range: float = 10

## 视线偏移
## 
## 视线相对于实体中心的位置偏移，类型为 [Vector2]。
@export var sight_offset: Vector2 = Vector2.ZERO
