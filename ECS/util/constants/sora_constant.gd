## @editing: Sora
## @describe: 游戏常量定义类 - 存储游戏中使用的所有静态常量
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
class_name SoraConstant
extends RefCounted

## 基础格子尺寸
## 用于网格对齐和位置计算的基本单位（像素）
const BASIC_CELL_SIZE: int = 8

## 实体状态枚举
## 定义实体可拥有的各种状态类型
## 0-99: 动态状态（如生命值），100+: 静态数值（如攻击力）
enum StatusEnum {
	# 动态状态信息 (0-99)
	Health = 0,    ## 生命值
	Magic,         ## 魔力值  
	Fitness,       ## 耐力值
	
	# 静态数值信息 (100+)
	AttackPoint = 100,  ## 攻击力
	DefendPoint,        ## 防御力
}

## 游戏基础设置配置
## 包含默认的键位映射、显示设置和音频设置
## 支持键盘和鼠标按键绑定的多种配置格式
const BASIC_SETTING: Dictionary = {
	"keymap": {
		# 基础移动操作（键盘）
		"move_l": KEY_A,           # 向左移动
		"move_r": KEY_D,           # 向右移动
		"move_u": KEY_W,           # 向上移动
		"move_d": KEY_S,           # 向下移动
		
		# 基础交互操作
		"interact": KEY_SPACE,     # 交互键
		
		# 鼠标按键映射示例
		"primary_action": {        # 主要动作（鼠标左键）
			"type": "mouse",
			"button": MOUSE_BUTTON_LEFT
		},
		"secondary_action": {      # 次要动作（鼠标右键）
			"type": "mouse", 
			"button": MOUSE_BUTTON_RIGHT
		},
		"special_action": {        # 特殊动作（Ctrl+鼠标左键）
			"type": "mouse",
			"button": MOUSE_BUTTON_LEFT,
			"ctrl": true
		},
		
		# 字符串格式的鼠标按键配置示例
		"context_menu": "mouse:right",          # 右键菜单
		"zoom_in": "mouse:wheel_up",           # 放大
		"zoom_out": "mouse:wheel_down",        # 缩小
		"quick_select": "mouse:middle+ctrl",   # 快速选择（Ctrl+中键）
		
		# 其他功能键
		"test_saving": KEY_O,      # 测试存档键
		"brain_trigger": KEY_TAB,  # 思维界面触发键
		"pause_game": KEY_P        # 暂停游戏键
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
enum {
	WINDOWED = 0,    ## 窗口模式
	FULLSCREEN       ## 全屏模式
}

## 分辨率设置枚举
enum {
	HD = 0,          ## 高清 (720p)
	SHD              ## 超高清 (1080p+)
}
#endregion

## 输入类型枚举
## 定义不同的输入检测方式
enum InputType {
	Pressed = 0,     ## 持续按住
	Released,        ## 释放按键
	JustPressed,     ## 刚按下
}

