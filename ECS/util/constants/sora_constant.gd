## 游戏常量定义类 - 存储游戏中使用的所有静态常量
##
## 该类集中管理游戏中的各种常量定义，包括：
## - 游戏基础设置参数
## - 状态和数值枚举
## - 默认配置值
## - 输入类型定义
##
## 设计原则：
## - 所有魔法数字都应在此处定义
## - 提供类型安全的枚举定义
## - 便于维护和修改游戏参数
##
## 常量分类：
## - 基础尺寸常量：用于游戏网格和对齐
## - 枚举定义：状态、输入、显示模式等
## - 配置字典：默认设置和键位映射
##
## 架构设计：
## - 继承自 [RefCounted] 基类
## - 使用 [enum StatusEnum] 定义实体状态类型
## - 通过 [const BASIC_SETTING] 字典管理默认配置
## - 基于 [enum InputType] 的输入检测类型
##
## [br][b]编辑者:[/b] Sora
class_name SoraConstant
extends RefCounted

## 基础格子尺寸
## 
## 用于网格对齐和位置计算的基本单位（像素）。
const BASIC_CELL_SIZE: int = 8

## 实体状态枚举
## 
## 定义实体可拥有的各种状态类型。
## 数值分区：0-99为动态状态，100+为静态数值。
enum StatusEnum {
	# 动态状态信息 (0-99) - 可变化的状态值
	Health = 0,    ## 生命值 - 实体的生存状态
	Magic,         ## 魔力值 - 施法资源
	Fitness,       ## 耐力值 - 行动资源
	
	# 静态数值信息 (100+) - 相对固定的属性值
	AttackPoint = 100,  ## 攻击力 - 造成伤害的能力
	DefendPoint,        ## 防御力 - 减少伤害的能力
}

## 游戏基础设置配置
## 
## 包含默认的键位映射、显示设置和音频设置。
## 支持键盘和鼠标按键绑定的多种配置格式。类型为 [Dictionary]。
const BASIC_SETTING: Dictionary = {
	"keymap": {
		## 通用的操作: 按键的映射是
		-1: {
		# 字符串格式的鼠标按键配置示例
			"context_menu": "mouse:right",          # 右键菜单
			"zoom_in": "mouse:wheel_up",           # 放大
			"zoom_out": "mouse:wheel_down",        # 缩小
			"quick_select": "mouse:middle+ctrl",   # 快速选择（Ctrl+中键）
			"brain_trigger": KEY_TAB,
			"pause_game": KEY_P,
			"test_saving": KEY_O,
			"open_command_line": {
				"type": "key",
				"keycode": KEY_C,
			}
		},

		0: {
			"movement": {
				"type": "mouse",
				"keycode": MOUSE_BUTTON_LEFT
			},
			"move_l": KEY_A,           # 向左移动
			"move_r": KEY_D,          # 向右移动
			"move_u": KEY_W,             # 向上移动
			"move_d": KEY_S,           # 向下移动
			"interact": {
				"type": "mouse",
				"keycode": MOUSE_BUTTON_LEFT
			},
			"primary_action": {        # 主要动作（鼠标左键）
				"type": "mouse",
				"keycode": MOUSE_BUTTON_WHEEL_UP
			},
			"secondary_action": {      # 次要动作（鼠标右键）
				"type": "mouse", 
				"keycode": MOUSE_BUTTON_RIGHT
			},
			"special_action": {        # 特殊动作（Ctrl+鼠标左键）
				"type": "mouse",
				"keycode": MOUSE_BUTTON_MIDDLE
			},
			"skill_0": {
				"type": "mouse",
				"keycode": MOUSE_BUTTON_MASK_MB_XBUTTON1
			},
			"skill_1": {
				"type": "mouse",
				"keycode": MOUSE_BUTTON_MASK_MB_XBUTTON2
			},
			"skill_2": {
				"type": "mouse",
				# "keycode": MOUSE_BUTTON_MASK_MIDDLE
			},
		},

		1: {
			"move_l": KEY_LEFT,           # 向左移动
			"move_r": KEY_RIGHT,          # 向右移动
			"move_u": KEY_UP,             # 向上移动
			"move_d": KEY_DOWN,           # 向下移动
			"interact": KEY_ENTER,        # 交互键
			"primary_action": {        # 主要动作（鼠标左键）
				"type": "key",
				"keycode": KEY_J
			},
			"secondary_action": {      # 次要动作（鼠标右键）
				"type": "key", 
				"keycode": KEY_K
			},
			"special_action": {        # 特殊动作（Ctrl+鼠标左键）
				"type": "key",
				"keycode": KEY_L,
				"ctrl": true
			},
			"skill_0": {
				"type": "key",
				"keycode": KEY_U
			},
			"skill_1": {
				"type": "key",
				"keycode": KEY_I
			},
			"skill_2": {
				"type": "key",
				"keycode": KEY_O
			},
		},
		2:{},
		3:{}
	},
	"display": {
		"window": WINDOWED,        # 窗口模式
		"definition": HD,          # 分辨率设置
	},
	"audio": {
		"master": 50,              # 主音量 (0-100)
		"bgm": 50,                 # 背景音乐音量
		"sfx": 50                  # 音效音量
	}
}

#region 显示设置枚举
## 窗口模式枚举
## 
## 定义游戏支持的窗口显示模式。
enum {
	WINDOWED = 0,    ## 窗口模式 - 在桌面窗口中运行
	FULLSCREEN       ## 全屏模式 - 独占整个屏幕
}

## 分辨率设置枚举
## 
## 定义游戏支持的分辨率级别。
enum {
	HD = 0,          ## 高清 (720p) - 标准高清分辨率
	SHD              ## 超高清 (1080p+) - 全高清及以上分辨率
}
#endregion

## 输入类型枚举
## 
## 定义不同的输入检测方式，用于精确的输入时机控制。
enum InputType {
	PRESSED = 0,     ## 持续按住 - 按键保持按下状态
	JUST_RELEASED,        ## 释放按键 - 按键刚被释放的状态
	JUST_PRESSED,     ## 刚按下 - 按键刚被按下的瞬间
}
enum InputTarget {
	COMMON = -1,
	PLAYER1 = 0,
	PLAYER2,
	PLAYER3,
	PLAYER4
}
