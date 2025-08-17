## 子系统抽象基类 - 游戏运行时的实时更新系统
##
## 该抽象类定义了子系统的标准接口和行为，提供持续运行和更新的系统架构。
## 所有需要实时更新的子系统都应该继承此类并实现抽象方法。
##
## 核心功能：
## - 继承自 [ISystem] 的基础系统功能
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
## 与 [ISystem] 的区别：
## - [ISystem]：一次性初始化的静态系统
## - [SubSystem]：需要持续更新的动态系统
##
## 架构设计：
## - 继承自 [ISystem] 基类
## - 使用 [annotation @abstract] 标记抽象类
## - 集成 [StringName] 的关键字识别系统
## - 支持 [SavedDataFile] 的存档持久化
##
## [br][b]编辑者:[/b] Sora
@abstract class_name SubSystem
extends ISystem

#region 子系统标识

## 子系统关键字
## 
## 用于在黑板系统中识别和管理该子系统，类型为 [StringName]。
var keyword: StringName

#endregion

#region 抽象接口

## 子系统更新方法（抽象方法）
## 
## 子类必须实现的实时更新逻辑。
## [param _delta]: 帧时间间隔，类型为 [float]
@abstract func _update(_delta: float)

#endregion

#region 存档系统接口

## 保存子系统数据（虚方法）
## 
## 子类可重写以实现自定义数据保存。
## [param _data]: 存档数据文件，类型为 [SavedDataFile]
func _save_as(_data: SavedDataFile):
	pass

## 加载子系统数据（虚方法）
## 
## 子类可重写以实现自定义数据加载。
## [param _data]: 存档数据文件，类型为 [SavedDataFile]
func _load_by(_data: SavedDataFile):
	pass

#endregion