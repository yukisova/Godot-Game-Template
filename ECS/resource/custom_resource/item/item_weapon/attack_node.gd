## 武器攻击节点基类， 定义武器攻击行为的核心接口
## 每个具体的武器类型都需要继承此类并实现具体的攻击逻辑
## 架构设计：继承自 [EquipmentNode] 基类，使用 [annotation @tool] 支持编辑器预览
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name WeaponNode
extends EquipmentNode

## 攻击发起点
## 标记动作发起的具体位置，如枪口、剑尖等
@export var fire_point: Marker2D

func set_hit_effect(_hit_effect_list: Array):
	pass
