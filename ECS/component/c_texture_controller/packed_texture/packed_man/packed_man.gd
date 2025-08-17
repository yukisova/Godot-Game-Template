extends IPackedSprite

@export var body: Sprite2D
@export var head: Sprite2D

@export var hand_left: Sprite2D
@export var hand_right: Sprite2D

## 纹理方向
var texture_award: Vector2 = Vector2.RIGHT
## 当前帧
var current_frame: int = 0

func toward(direction: Vector2) -> void:
    texture_award = direction
    if texture_award.x >= 0.0:
        current_frame = 0 if texture_award.y >= -0.1 else 1
    else:
        current_frame = 3 if texture_award.y >= -0.1 else 2

    body.flip_h = texture_award.x < 0.0
    head.flip_h = texture_award.x < 0.0
    body.frame = 0 if texture_award.y >= -0.1 else 1
    head.frame = 0 if texture_award.y >= -0.1 else 1

## 状态控制变量
var status_code: int = 0
## 节奏
var rhythm: float = 5.0
## 节拍
var beat: float = 0.0
## 峰值谷值
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
#             body.rotation = -beat * 0.2
#             body.skew = beat * 0.2
#             rhythm = 10.0
#             local_status_code = 1
#             position.y = -abs(beat) * 20
#         else:
#             head.offset.y = beat * 5.0
#             body.scale.x = 1.0 + beat * 0.1
#             rhythm = 5.0
#             local_status_code = 0
#             position.y = 0.0
#     else:
#         local_status_code = 10
#         rhythm = 0.0
#         position.y = -entity.z_index
