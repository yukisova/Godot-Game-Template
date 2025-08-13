## @editing: Sora
## @describe: PDA状态基类 - 下推自动机状态的抽象实现
## 
## 该抽象类定义了PDA（Push-Down Automaton，下推自动机）状态的基础结构。
## PDA状态被设计用于实现可中断、可恢复的状态逻辑，通过状态栈管理复杂的状态层次。
## 
## PDA特性：
## - 状态标识：通过关键词唯一标识状态
## - 状态归属：明确状态所属的HFSM状态
## - 上下文管理：状态间的数据传递和共享
## - 触发机制：支持弹出和完成触发器
## - 模糊更新：后台状态的持续处理能力
## 
## 触发器机制：
## - pop_trigger：用于请求从状态栈中弹出当前状态
## - plus_trigger：用于标识状态目标达成，触发特殊处理
## - blur_update_enable：控制是否在非激活时执行模糊更新
## 
## 应用场景：
## - 中断恢复：支持中断和恢复的复杂操作
## - 临时状态：短期的、可叠加的状态效果
## - 上下文保持：需要保持历史信息的状态
## - 嵌套行为：可以嵌套在其他状态中的子行为
@tool
@abstract class_name StatePda
extends State

## 状态关键词
## 用于唯一标识PDA状态的字符串名称
## TODO: 考虑使用UUID来提高唯一性保证
var keyword: StringName

## 归属状态
## 指向管理此PDA状态的HFSM状态实例
var belong_state: StateHfsm

## 状态上下文
## 存储状态执行所需的上下文信息，由HFSM状态提供和管理
var state_context: Dictionary

## 弹出触发器
## 当设置为true时，请求从状态栈中弹出当前状态
## 同时会自动重置plus_trigger以保持状态一致性
var pop_trigger: bool = false:
	set(v):
		pop_trigger = v
		if not v:
			plus_trigger = v

## 完成触发器  
## 标识PDA状态已达成其内部目标，用于通知HFSM状态进行特殊处理
## 与pop_trigger类似，但语义上表示状态的成功完成而非简单退出
var plus_trigger: bool = false

## 模糊更新启用标志
## 控制状态在非激活时是否执行模糊更新逻辑
var blur_update_enable: bool = false

## 模糊更新
## 当状态不是栈顶状态但仍在栈中时执行的后台更新逻辑
## 用于处理需要持续监控或准备的操作
## @param _delta: 帧时间间隔
func _blur_update(_delta: float):
	# 基类默认不执行模糊更新，子类可根据需要重写
	pass

## 设置状态上下文
## 提供便捷的上下文数据设置方法
## @param key: 上下文键名
## @param value: 上下文值
func set_context(key: String, value: Variant):
	state_context[key] = value

## 获取状态上下文
## 提供便捷的上下文数据获取方法
## @param key: 上下文键名
## @param default: 默认值
## @return: 上下文值或默认值
func get_context(key: String, default: Variant = null) -> Variant:
	return state_context.get(key, default)

## 请求弹出状态
## 设置弹出触发器，请求从状态栈中移除当前状态
func request_pop():
	pop_trigger = true

## 标记状态完成
## 设置完成触发器，标识状态已达成目标
func mark_completed():
	plus_trigger = true
