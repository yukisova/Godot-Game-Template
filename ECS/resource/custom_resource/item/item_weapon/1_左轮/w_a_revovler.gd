extends ItemWeapon

@export var bullet_clip: Array[String]:
    set(v):
        bullet_clip = v
        bullet_clip.resize(current_bullet_clip_num)

var current_bullet_clip_num: BulletClipNum = BulletClipNum.L1

enum BulletClipNum {
    L1 = 6,
    L2 = 8,
    L3 = 12
}