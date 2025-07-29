##@editing:	Sora
##@describe:	是专门进行过场剧情的，会根据传入的逻辑参数进行指定的剧情处理
##			可能存在多个剧情，因此没有需要继承的方法，根据需要进行动态的运行
@abstract class_name Cutscene
extends Node

signal cutscene_started ## 过场剧情开始执行信号
signal cutscene_ended(return_context: Dictionary) ## 过场剧情结束信号

## 过场剧情依赖项检查
func cutscene_dependencies_check(check_list: Array, check_dict: Dictionary) -> bool:
	var result = []
	for info in check_list:
		if !check_dict.has(info):
			result.append(info)
	if !result.is_empty():
		push_error("依赖项", result, "缺失，需要检查传入参数")
		return false
	return true
