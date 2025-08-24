## PDA状态基类 - 下推自动机状态的抽象实现
## 定义PDA（Push-Down Automaton）状态的基础结构，用于实现可中断、可恢复的状态逻辑
## PDA特性：状态标识、状态归属、上下文管理、触发机制、模糊更新
## 应用场景：中断恢复、临时状态、上下文保持、嵌套行为
## [br][b]编辑者:[/b] Sora
@tool
@abstract class_name StatePda
extends IState

## 状态关键词，用于唯一标识PDA状态的字符串名称
## TODO: 考虑使用UUID来提高唯一性保证
var keyword: StringName

## 归属状态，指向管理此PDA状态的HFSM状态实例
var belong_state: StateHfsm

## 状态上下文，存储状态执行所需的上下文信息，由HFSM状态提供和管理
var state_context: Dictionary

## 弹出触发器，设置为true时请求从状态栈中弹出当前状态
## 同时会自动重置plus_trigger以保持状态一致性
var pop_trigger: bool = false:
	set(v):
		pop_trigger = v
		if not v:
			plus_trigger = -1

## 完成触发器，标识PDA状态已达成其内部目标，用于通知HFSM状态进行特殊处理
## 与pop_trigger类似，但语义上表示状态的成功完成而非简单退出

## 完成触发器
@export var plus_trigger_target: Array[StatePda]

var plus_trigger: int = -1

## 模糊更新启用标志，控制状态在非激活时是否执行模糊更新逻辑
var blur_update_enable: bool = false

## 模糊更新，当状态不是栈顶状态但仍在栈中时执行的后台更新逻辑
## [param _delta]: 帧时间间隔
func _blur_update(_delta: float):
	# 基类默认不执行模糊更新，子类可根据需要重写
	pass

## 设置状态上下文，提供便捷的上下文数据设置方法
## [param key]: 上下文键名，类型为 [String]
## [param value]: 上下文值，类型为 [Variant]
func set_context(key: String, value: Variant):
	state_context[key] = value

## 获取状态上下文，提供便捷的上下文数据获取方法
## [param key]: 上下文键名，类型为 [String]
## [param default]: 默认值，类型为 [Variant]
## [br][br][b]返回:[/b] 上下文值或默认值
func get_context(key: String, default: Variant = null) -> Variant:
	return state_context.get(key, default)

## 请求弹出状态，设置弹出触发器，请求从状态栈中移除当前状态
func request_pop():
	pop_trigger = true

## 标记状态完成，设置完成触发器，标识状态已达成目标
func mark_completed():
	plus_trigger = true
