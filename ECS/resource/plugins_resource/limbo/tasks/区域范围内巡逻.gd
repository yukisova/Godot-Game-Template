# 区域范围内巡逻
# 在区域范围内巡逻，并返回巡逻路径
# 参数：
# - 区域：区域ID
# - 巡逻路径：巡逻路径ID
# - 巡逻速度：巡逻速度
# - 巡逻时间：巡逻时间
# - 巡逻距离：巡逻距离
# - 巡逻方向：巡逻方向
# - 巡逻方式：巡逻方式
extends BTAction

func _tick(delta: float) -> Status:
	return Status.SUCCESS


