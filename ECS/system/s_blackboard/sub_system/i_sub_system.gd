## @editing: Sora [br]
## @describe: 子系统抽象基类 - 游戏运行时的实时更新系统
##
## 该抽象类定义了子系统的标准接口和行为：
## - 继承自ISystem的基础系统功能
## - 添加实时更新机制（类似Unity的Update）
## - 提供子系统的标识符管理
## - 集成存档系统的数据持久化
##
## 设计特点：
## - 抽象类强制实现关键方法
## - 统一的更新循环接口
## - 基于关键字的子系统识别
## - 标准化的存档接口
##
## 主要功能：
## - 实时数据更新和计算
## - 游戏逻辑的持续监控
## - 状态变化的响应处理
## - 数据的自动保存和加载
##
## 使用场景：
## - 时间循环系统
## - 剧情分支系统
## - 物品合成系统
## - 环境效果系统
##
## 与ISystem的区别：
## - ISystem：一次性初始化的静态系统
## - SubSystem：需要持续更新的动态系统
@abstract class_name SubSystem
extends ISystem

#region 子系统标识

## 子系统关键字
## 用于在黑板系统中识别和管理该子系统
var keyword: StringName

#endregion

#region 抽象接口

## 子系统更新方法（抽象）
## 子类必须实现的实时更新逻辑
## @param _delta: 帧时间间隔
@abstract func _update(_delta: float)

#endregion

#region 存档系统接口

## 保存子系统数据（虚方法）
## 子类可重写以实现自定义数据保存
## @param data: 存档数据文件
func _save_as(_data: SavedDataFile):
	pass

## 加载子系统数据（虚方法）
## 子类可重写以实现自定义数据加载
## @param data: 存档数据文件
func _load_by(_data: SavedDataFile):
	pass

#endregion