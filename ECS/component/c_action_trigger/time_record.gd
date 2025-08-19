## 时间记录资源 - 时间循环系统的事件配置
## 该资源类用于配置时间循环系统中的特定时间事件，允许在特定时间触发指定的游戏事件或动作
## 主要用途：定时触发游戏事件、配置日夜循环中的特殊时刻、管理基于时间的剧情节点
## 配置参数：目标时间、事件标识、事件路径
## 架构设计：继承自 [Resource] 基类，使用 [annotation @export] 导出配置参数
## [br][b]编辑者:[/b] Sora
class_name TimeRecord
extends Resource

## 目标小时
## 事件触发的目标小时（24小时制）
@export var target_hour: int

## 目标分钟
## 事件触发的目标分钟
@export var target_minute: int

## 目标事件关键字
## 用于识别特定事件类型的关键字字符串
@export var target_event_keyword: String

## 目标事件路径
## 指向要执行的事件动作节点的路径，类型为 [NodePath]
@export_node_path("IAction") var target_event_path: NodePath