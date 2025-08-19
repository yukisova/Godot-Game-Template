## [b]打包人物精灵实现类[/b]
##
## 继承自[color=blue]IPackedSprite[/color]，实现具体的人物精灵动画控制。[br]
## 提供基于节拍的动画系统和状态管理功能。
##
## [b]主要功能:[/b]
## [color=green]•[/color] 基于[b]节拍系统[/b]的动画控制[br]
## [color=green]•[/color] [b]状态驱动[/b]的精灵切换[br]
## [color=green]•[/color] [b]峰值谷值[/b]动画曲线控制[br]
## [color=green]•[/color] 与[color=purple]CActionTrigger[/color]组件集成
##
## [b]动画系统:[/b]
## [color=yellow]•[/color] 支持[color=red]节拍驱动[/color]的动画播放[br]
## [color=yellow]•[/color] 可配置的[color=red]节奏速度[/color][br]
## [color=yellow]•[/color] [color=red]峰值谷值[/color]控制动画幅度
##
## [br][b]编辑者:[/b] [color=purple]Sora[/color]
extends IPackedSprite

## [b]状态控制变量[/b]
## 
## 当前精灵的状态码，用于控制不同的动画状态。
var status_code: int = 0

## [b]节奏[/b]
## 
## 动画播放的节奏速度，值越大动画越快。[br]
## 默认值为[color=green]5.0[/color]。
var rhythm: float = 5.0

## [b]节拍[/b]
## 
## 当前动画的节拍位置，随时间递减。[br]
## 用于计算动画的当前状态。
var beat: float = 0.0

## [b]峰值谷值[/b]
## 
## 控制动画的振幅范围，影响动画的强度。[br]
## 正值和负值会产生不同的动画效果。
var peak_valley: float = 1.0

# ## 使用代码控制动画
# func body_movement(entity: FixedEntity, delta: float):
#     if peak_valley > 0:
#         beat -= rhythm * delta
#         if beat <= -peak_valley * peak_valley - 1.0:
#             pass
#     else:
#         beat -= rhythm * delta
#         if beat <= peak_valley * peak_valley - 1.0:
#             pass
	
#     var local_status_code: int = 0

#     var action_trigger: CActionTrigger= entity.list_base_components.get(IComponent.ComponentName.C_ACTION_TRIGGER, null)
#     if action_trigger != null and action_trigger.current_action.has("on_floor"):
#         if action_trigger.current_action == "movement":
#             sprite_body.rotation = -beat * 0.2
#             sprite_body.skew = beat * 0.2
#             rhythm = 10.0
#             local_status_code = 1
#             position.y = -abs(beat) * 20
#         else:
#             sprite_head.offset.y = beat * 5.0
#             sprite_body.scale.x = 1.0 + beat * 0.1
#             rhythm = 5.0
#             local_status_code = 0
#             position.y = 0.0
#     else:
#         local_status_code = 10
#         rhythm = 0.0
#         position.y = -entity.z_index
