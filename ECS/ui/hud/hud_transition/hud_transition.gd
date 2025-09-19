## 过渡HUD - 处理场景切换和过渡效果的专业化界面系统
## 该HUD系统专门用于管理游戏中的各种过渡效果，提供流畅的视觉体验
## 支持多种过渡效果和自定义动画，确保场景切换的专业化表现
## 核心功能：高质量的淡入淡出动画、灵活的过渡时长控制、异步操作的完整支持
## 过渡效果类型：标准过渡（1.5秒）、快速过渡（0.5秒）、自定义时长、黑屏遮罩
## 使用场景：关卡之间的无缝切换、游戏开始和结束的专业表现、剧情片段的流畅衔接
## 架构设计：继承自 [UIHudController] 基类，基于 [ColorRect] 的遮罩实现，使用 [Tween] 系统的动画控制
## [br][b]编辑者:[/b] Sora
extends UIHudController

#region UI组件

## 黑色矩形遮罩
## 用于实现淡入淡出效果的主要UI元素，通过调整其透明度来创建各种过渡效果

#endregion

#region HUD生命周期

## HUD初始化（重写方法）
## 设置过渡效果的初始状态，确保遮罩处于透明状态。
func _initialize():
	print("过渡HUD: 初始化完成")

## HUD刷新（重写方法）
## 更新过渡状态，当前为预留接口。
func _refresh():
	pass

func fade_in():
	ui_view.fade_in()

func fade_out():
	ui_view.fade_out()

#endregion
