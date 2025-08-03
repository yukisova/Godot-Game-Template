## @editing: Sora [br]
## @describe: 只在游戏运行时才会正常运行并监控的项目子系统，与子系统的最大不同，就是也使用了类似update的方式
@abstract class_name SubSystem
extends ISystem

var keyword: StringName

@abstract func _update(_delta: float)
