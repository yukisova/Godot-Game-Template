## 相机跟随策略基类 - 定义相机跟随行为的抽象接口
## 该抽象类为所有相机跟随策略提供统一的接口。相机跟随策略采用策略模式设计，允许在运行时动态切换不同的相机行为。
## 策略类型：直接跟随、平滑跟随、鼠标辅助、预测跟随、区域限制
## 功能特性：策略模式设计、与相机组件无缝集成、可配置的跟随参数、平滑过渡支持
## [br][b]编辑者:[/b] Sora
@abstract class_name CameraFollowStrategy
extends Node

## 绑定的相机组件
## 策略将作用于此相机组件，由相机组件在初始化时设置
var c_camera: CCamera

## 执行跟随策略，每帧调用的核心相机跟随逻辑实现
## [param _delta]: 帧时间间隔
@abstract func _strategy(_delta: float) -> void
