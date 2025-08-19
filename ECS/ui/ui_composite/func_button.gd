## 功能按钮 - 支持参数传递的增强按钮组件
## 该按钮扩展了 [Button] 的功能，提供预设参数的存储和传递、灵活的事件处理机制
## 主要用途：菜单按钮的参数化配置、动态生成的按钮列表、需要传递特定数据的交互控件
## 参数类型支持：场景路径（界面跳转）、实体引用（对象操作）、配置数据（设置传递）
## 架构设计：继承自 [Button] 基类，基于 [Array] 的参数存储，支持任意 [Variant] 类型数据
## [br][b]编辑者:[/b] Sora
class_name FuncButton
extends Button

#region 按钮参数

## 按钮参数数组
## 存储按钮点击时需要传递的参数列表，支持任意类型的 [Variant] 数据
@export var args: Array[Variant]

#endregion
