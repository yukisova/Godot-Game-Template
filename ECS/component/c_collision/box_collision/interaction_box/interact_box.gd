## @editing: Sora [br]
## @describe: 交互碰撞盒 - 处理实体间交互检测的碰撞区域
## 
## 该类实现了基于区域检测的交互系统，当其他实体进入或离开交互区域时
## 可以触发相应的交互事件。主要用于实现自动交互或交互提示功能。
## 
## 交互特性：
## - 区域触发：基于Area2D的进入/离开检测
## - 自动检测：无需玩家主动操作即可触发
## - 灵活配置：可配置交互区域的大小和形状
## - 群组过滤：支持特定群组的交互对象过滤
## 
## 应用场景：
## - 自动门：玩家接近时自动开启
## - 提示区域：显示交互提示UI
## - 收集物品：自动收集范围内的物品
## - 触发器：进入特定区域触发事件
## - NPC对话：接近NPC时显示对话选项
## 
## 使用方法：
## 1. 将此碰撞盒添加到需要交互检测的实体
## 2. 配置碰撞形状和检测层级
## 3. 连接body_entered和body_exited信号
## 4. 在信号处理函数中实现交互逻辑
class_name InteractBox
extends BoxCollision

func _enter_tree() -> void:
	box_collision_name = CCollision.BoxCollisionName.INTERACT
	collision_layer = Main.PhysicsLayer.Interactable
