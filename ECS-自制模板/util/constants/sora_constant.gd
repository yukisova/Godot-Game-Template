##@editing:	Sora
##@describe:	静态的常量调用类
class_name SoraConstant
extends RefCounted

const BASIC_CELL_SIZE:int = 8 ## 单位格子的大小

enum StatusEnum{
	Health = 0, ## 血量
	Magic, ## 魔力
	Fitness, ## 耐力
	
	AttackPoint = 100,
	DefendPoint,
} ## 状态枚举


const BASIC_SETTING: Dictionary = {
	"keymap": {
		"move_l": KEY_A,
		"move_r": KEY_D,
		"move_u": KEY_W,
		"move_d": KEY_S,
		"interact": KEY_SPACE,
		"test_saving": KEY_O,
		"brain_trigger": KEY_I,
		"pause_game": KEY_P
	},
	"display": {
		"window": WINDOWED,
		"definition": HD,
	},
	"audio": {
		"master": 50,
		"bgm": 50,
		"sfx": 50
	}
}

#region 设置信息枚举变量
enum {
	WINDOWED = 0,
	FULLSCREEN
	
}
enum {
	HD = 0,
	SHD
}
#endregion

enum InputType{
	Pressed = 0,
	Released,
	JustPressed,
}
