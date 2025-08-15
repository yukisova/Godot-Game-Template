## @editing: Sora [br]
## @describe: 武器攻击节点基类 - 定义武器攻击行为的核心接口
##
## 该类是所有武器攻击节点的抽象基类，定义了武器攻击的标准接口和基础结构。
## 每个具体的武器类型都需要继承此类并实现具体的攻击逻辑。
##
## 设计理念：
## - 策略模式：每种武器攻击方式都是一个独立的策略
## - 可扩展性：轻松添加新的武器类型和攻击模式
## - 标准接口：所有武器都通过相同的接口进行攻击
## - 组件化：作为独立节点，可以动态挂载和卸载
##
## 核心功能：
## - 攻击接口：定义标准的 _attack() 方法
## - 攻击点管理：通过 fire_point 标记攻击发起位置
## - 编辑器支持：使用 @tool 标记支持编辑器内预览
## - 继承扩展：子类可以扩展实现具体攻击逻辑
##
## 攻击系统架构：
## 1. 玩家触发攻击输入
## 2. 装备系统调用当前武器的 _attack() 方法
## 3. 具体攻击节点执行攻击逻辑
## 4. 生成攻击效果（子弹、伤害、特效等）
##
## 子类实现指南：
## - 继承 WeaponAttackNode 基类
## - 重写 _attack() 方法实现具体攻击逻辑
## - 使用 fire_point 作为攻击发起位置
## - 可添加额外的配置参数和功能
##
## 应用场景：
## - 近战攻击：剑击、拳击等近距离攻击
## - 远程攻击：射箭、开枪等远距离攻击
## - 魔法攻击：施法、法术释放等
## - 特殊攻击：技能释放、特殊能力等
##
## 使用示例：
## ```gdscript
## class_name PistolAttackNode
## extends WeaponAttackNode
##
## func _attack():
##     var bullet = bullet_scene.instantiate()
##     bullet.global_position = fire_point.global_position
##     get_tree().current_scene.add_child(bullet)
## ```
@tool
class_name WeaponAttackNode
extends Node2D

## 攻击发起点
## 标记武器攻击的起始位置，用于确定子弹发射点、近战攻击范围中心等
## 通常放置在武器的枪口、剑尖或法杖顶端等逻辑攻击位置
@export var fire_point: Marker2D
var c_status: CStatus
var hit_effect_list: Array[IHitEffect]

func _ready() -> void:
	pass

## 攻击方法（抽象）
## 所有武器攻击节点都必须实现的核心攻击逻辑
## 子类应重写此方法来实现具体的攻击行为
## 
## 实现建议：
## - 使用 fire_point.global_position 作为攻击起始位置
## - 添加攻击冷却时间控制
## - 包含音效和视觉特效
## - 处理弹药消耗（如适用）
func _attack():
	# 子类应重写此方法实现具体攻击逻辑
	pass
