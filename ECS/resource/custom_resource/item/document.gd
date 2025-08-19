## 文档资源类 - 游戏中各种文档和书籍的数据载体
## 该类定义了游戏中出现的各种文档、书籍、信件等可阅读内容的数据结构
## 支持富文本内容、图片插入和自定义背景，为游戏提供丰富的阅读体验
## 功能特性：富文本内容、图片支持、自定义背景、资源管理
## 应用场景：游戏剧情、任务日志、世界观设定、教学指南、收集品
## [br][b]编辑者:[/b] Sora
class_name Document
extends Resource

## 文档标题
## 显示在文档界面顶部的标题文字
@export var ducument_title: String

## 文档内容
## 文档的主要文本内容，支持多行和富文本格式
@export_multiline var document_content: String

## 文档图片集合
## 根据标识符存储的图片资源，可在文档内容中引用显示
@export var document_images: Dictionary[StringName, Texture2D]

## 文档背景纹理
## 显示文档时使用的背景图片，用于营造不同文档类型的视觉效果
@export var document_background: Texture2D
