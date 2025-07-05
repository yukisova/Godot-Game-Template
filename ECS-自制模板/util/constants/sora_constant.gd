class_name SoraConstant
extends RefCounted

const BASIC_CELL_SIZE:int = 8 ## 单位格子的大小

enum StatusEnum{
	Health = 0,
	
	Sleep = 100,
	
	AttackPoint = 200,
	DefendPoint,
} ## 状态枚举

enum ToolMode { Axe, Splash, Hoe }

const BASIC_SETTING: Dictionary = {
	"keymap": {
		"move_l": KEY_A,
		"move_r": KEY_D,
		"move_u": KEY_W,
		"move_d": KEY_S,
		"test_saving": KEY_O,
		"brain_trigger": KEY_TAB,
		"pause_game": KEY_P
	},
	"display": {
		"mode": Windowed,
	},
	"audio": {
		"master": 50
	}
}

enum {
	FullScreen,
	Windowed
}
