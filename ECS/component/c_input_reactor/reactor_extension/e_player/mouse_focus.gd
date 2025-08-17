## 鼠标焦点扩展 - 使指定节点跟随鼠标位置移动
## 
## 该扩展用于让特定的Node2D节点始终跟随鼠标光标的位置移动。
## 常用于准星、鼠标指针、瞄准器等需要跟随鼠标的游戏元素。
## 
## 核心功能：
## - 多节点的同步跟随
## - 实时的位置更新
## - 高效的实现机制
## - 安全的节点验证
## 
## 跟随特性：
## - 全局坐标系统：直接使用鼠标的全局坐标
## - 多节点支持：同时控制多个跟随节点
## - 实时更新：每帧同步更新节点位置
## - 节点验证：自动检查节点的有效性
## 
## 应用场景：
## - 游戏准星显示：FPS游戏的瞄准准星
## - 鼠标光标替换：自定义鼠标指针
## - 瞄准器跟随：各种武器的瞄准器
## - 鼠标交互指示器：UI交互的视觉反馈
## - 建造系统：建筑预览的位置跟随
## 
## 技术特点：
## - 多节点同步跟随：支持数组配置多个节点
## - 实时位置更新：每帧调用确保流畅跟随
## - 简单高效的实现：最小的性能开销
## - 自动错误处理：节点失效时的安全处理
##
## 架构设计：
## - 继承自 [ReactorExtension] 基类
## - 基于 [Array] of [Node2D] 的多节点管理
## - 使用全局鼠标位置的坐标系统
## - 集成视口的鼠标位置获取
##
## [br][b]编辑者:[/b] Sora
class_name MouseFocusExtension
extends ReactorExtension

## 鼠标焦点节点数组
## 
## 所有在此数组中的Node2D节点都会跟随鼠标位置移动，类型为 [Array] of [Node2D]。
@export var mouse_focus: Array[Node2D]

## 监听鼠标位置更新（重写方法）
## 
## 每帧更新所有焦点节点的位置到鼠标位置。
func _listen():
	# 遍历所有焦点节点，将其位置设置为鼠标位置
	for focus_node in mouse_focus:
		if is_instance_valid(focus_node):
			focus_node.global_position = focus_node.get_global_mouse_position() if get_viewport() else Vector2.ZERO
