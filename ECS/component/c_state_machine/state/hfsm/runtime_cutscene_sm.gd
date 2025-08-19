## 运行时过场状态机 - 统一管理游戏过场动画的状态流程
## 专门用于控制游戏中的过场动画和剧情序列
## 核心状态：cutscene_waiting等待、cutscene_running运行、cutscene_finished完成、cutscene_pause暂停
## 主要功能：统一过场状态管理、标准化流程、可扩展状态方法字典、Callable动态绑定
## [br][b]编辑者:[/b] Sora
@tool
class_name RuntimeCutsceneSM
extends StateMachineAIO

## 状态机设置（重写方法）
## 
## 初始化所有过场状态的方法绑定和默认状态设置。
func _setup() -> void:
	super()
	state_method_dict["cutscene_waiting"] = {
		"enter": Callable(_enter_of_cutscene_waiting),
		"update": Callable(_update_of_cutscene_waiting),
		"exit": Callable(_exit_of_cutscene_waiting)
	}
	state_method_dict["cutscene_running"] = {
		"enter": Callable(_enter_of_cutscene_running),
		"update": Callable(_update_of_cutscene_running),
		"exit": Callable(_exit_of_cutscene_running)
	}
	state_method_dict["cutscene_finished"] = {
		"enter": Callable(_enter_of_cutscene_finished),
		"update": Callable(_update_of_cutscene_finished),
		"exit": Callable(_exit_of_cutscene_finished)
	}
	state_method_dict["cutscene_pause"] = {
		"enter": Callable(_enter_of_cutscene_pause),
		"update": Callable(_update_of_cutscene_pause),
		"exit": Callable(_exit_of_cutscene_pause)
	}
	init_state_str = "cutscene_waiting"
	current_state_str = init_state_str
	

## 状态机进入（重写方法）
## 
## 调用当前状态的进入方法。
func _enter():
	state_method_dict[current_state_str].enter.call()

## 状态机退出（重写方法）
## 
## 调用当前状态的退出方法。
func _exit():
	state_method_dict[current_state_str].exit.call()


#region 等待过场启动状态

## 进入等待过场启动状态
## 
## 过场动画开始前的准备阶段，子类可重写实现具体逻辑。
func _enter_of_cutscene_waiting():
	pass

## 更新等待过场启动状态
## 
## 等待状态的每帧更新逻辑，子类可重写实现具体逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_waiting(_delta: float):
	pass

## 退出等待过场启动状态
## 
## 离开等待状态时的清理逻辑，子类可重写实现具体逻辑。
func _exit_of_cutscene_waiting():
	pass

#endregion

#region 过场播放状态

## 进入过场播放状态
## 
## 过场动画正在播放时的初始化逻辑，子类可重写实现具体逻辑。
func _enter_of_cutscene_running():
	pass
	
## 更新过场播放状态
## 
## 过场播放期间的每帧更新逻辑，子类可重写实现具体逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_running(_delta: float):
	pass
	
## 退出过场播放状态
## 
## 过场播放结束时的清理逻辑，子类可重写实现具体逻辑。
func _exit_of_cutscene_running():
	pass

#endregion

#region 过场完成状态

## 进入过场完成状态
## 
## 过场动画完成后的处理逻辑，子类可重写实现具体逻辑。
func _enter_of_cutscene_finished():
	pass

## 更新过场完成状态
## 
## 过场完成状态的每帧更新逻辑，子类可重写实现具体逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_finished(_delta: float):
	pass

## 退出过场完成状态
## 
## 离开完成状态时的清理逻辑，子类可重写实现具体逻辑。
func _exit_of_cutscene_finished():
	pass

#endregion

#region 过场暂停状态

## 进入过场暂停状态
## 
## 过场暂停（如对话交互）时的处理逻辑，子类可重写实现具体逻辑。
func _enter_of_cutscene_pause():
	pass

## 更新过场暂停状态
## 
## 过场暂停期间的每帧更新逻辑，子类可重写实现具体逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
func _update_of_cutscene_pause(_delta: float):
	pass

## 退出过场暂停状态
## 
## 暂停结束恢复过场时的清理逻辑，子类可重写实现具体逻辑。
func _exit_of_cutscene_pause():
	pass

#endregion
