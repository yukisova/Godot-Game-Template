## HUD界面基类 - 游戏内界面元素的抽象基类
## HUD（Head-Up Display）是游戏中显示在屏幕上的界面元素，用于显示游戏状态信息
## 生命周期：在游戏实体加载完毕后激活、在进入GamingNormal状态时开始运行
## 功能特性：实时游戏信息显示、状态变化响应、与游戏实体数据绑定、自动刷新机制
## 架构设计：基于 [CanvasLayer] 的界面层级管理、抽象方法定义统一的HUD接口
## [br][b]编辑者:[/b] Sora
@abstract class_name IHud
extends CanvasLayer

## 当游戏状态或绑定实体数据发生变化时调用，子类需要实现具体的界面更新逻辑
@abstract func _refresh()

## 设置HUD的初始状态和数据绑定，子类需要实现具体的初始化逻辑
@abstract func _initialize()
