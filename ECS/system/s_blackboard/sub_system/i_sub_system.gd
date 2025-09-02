## 子系统抽象基类 - 游戏运行时的实时更新系统
## 该抽象类定义了子系统的标准接口和行为，提供持续运行和更新的系统架构
## 所有需要实时更新的子系统都应该继承此类并实现抽象方法
## 核心功能：继承自 [ISystem] 的基础系统功能、添加实时更新机制、提供子系统的标识符管理
## 使用场景：时间循环系统、剧情分支系统、物品合成系统、环境效果系统
## 与 [ISystem] 的区别：SubSystem需要持续更新的动态系统，ISystem是一次性初始化的静态系统
## 架构设计：继承自 [ISystem] 基类，使用 [annotation @abstract] 标记抽象类
## [br][b]编辑者:[/b] Sora
@abstract class_name ISubSystem
extends ISystem

enum SubSystemType {
	TIME_LOOP,
	ITEM_FUSION,
	STORYER,
	ENVIRONMENT,
}

#region 子系统标识

## 子系统关键字
## 用于在黑板系统中识别和管理该子系统，类型为 [StringName]
var keyword: SubSystemType

#endregion

#region 抽象接口

## 子类必须实现的实时更新逻辑
## [param _delta]: 帧时间间隔，类型为 [float]
@abstract func _update(_delta: float)

#endregion

#region 存档系统接口

## 子类可重写以实现自定义数据保存
## [param _data]: 存档数据文件，类型为 [SavedDataFile]
func _save_as(_data: SavedDataFile):
	pass

## 子类可重写以实现自定义数据加载
## [param _data]: 存档数据文件，类型为 [SavedDataFile]
func _load_by(_data: SavedDataFile):
	pass

#endregion
