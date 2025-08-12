## 游戏中可能会出现的各种文档的名称
class_name Document
extends Resource

@export var ducument_title: String
@export_multiline var document_content: String
@export var document_images: Dictionary[StringName, Texture2D] ## 根据需要可能会插入文章的图片
@export var document_background: Texture2D ## 观看图片的时候对应的背景
