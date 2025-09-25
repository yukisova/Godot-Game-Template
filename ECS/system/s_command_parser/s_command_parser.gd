## 命令行解析器系统 - 开发和调试时的实时命令执行工具
## 提供类似控制台的命令行界面，支持快捷键调用和实时命令执行
## 主要用于开发调试、功能测试和游戏参数修改
## [br][b]编辑者:[/b] Sora
extends ISystem

signal command_run_started(command_string: String)

@export_flags("无bgm", "无时间", "无过场") var debug_setting: int
enum DebugFlag{
	无bgm = 1 << 0,
	无时间概念 = 1 << 1,
	无过场剧情 = 1 << 2
}


const command_meta: Array[String] = ["quit"]

func _setup():
	command_run_started.connect(_on_command_run_started)

func _on_command_run_started(command_string: String):
	var parts = Array(command_string.split(" ")).map(func(v: String): return v.strip_edges())
	if parts.is_empty(): return
	if parts[0] == "quit":
		print("游戏根据命令强制退出")
		get_tree().quit(200)
