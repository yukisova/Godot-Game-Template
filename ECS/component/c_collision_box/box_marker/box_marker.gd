## 每个标记都可能有自己的作用，目前有以下几种：
## 1. 对话标记：用于标记对话触发位置
## 2. 特效标记: 用于标记粒子特效生成的位置
## 3. UE标记: 用于标记实体的指定UE生成的位置
## 4. 其他标记: 用于标记其他重要位置

## 继承自Marker2D，用于在场景中标记对话相关的重要位置
## [br][b]编辑者:[/b] Sora

@abstract class_name BoxMarker
extends Marker2D

@abstract func _update(_delta: float) -> void
