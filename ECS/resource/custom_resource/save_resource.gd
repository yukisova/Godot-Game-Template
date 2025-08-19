## 游戏存档数据文件 - 统一管理所有需要持久化的游戏数据
## 该资源类定义了游戏存档的完整数据结构，提供统一的数据持久化接口
## 涵盖玩家、实体、地图和系统的全方位数据存储需求
## 核心功能：玩家角色的状态和进度信息存储、地图中静态实体的状态数据管理、地图缓存和层级信息的维护
## 数据分类：玩家数据、静态实体、地图数据、系统数据
## 存储策略：使用JSON格式进行序列化和反序列化、支持增量保存和完整保存模式
## 架构设计：继承自 [Resource] 基类，使用 [annotation @export] 导出所有存档字段
## [br][b]编辑者:[/b] Sora
class_name SavedDataFile
extends Resource

#region 玩家数据

## 玩家信息字典
## 存储玩家角色的所有状态数据，包含位置、属性、等级、经验等核心信息
@export var player_info = {}

#endregion

#region 实体数据

## 静态实体数据字典
## 存储地图中预设实体的状态信息，包含静态实体（NPC、机关、收集品）和动态实体（不保存）
@export var static_entity = {}

#endregion

#region 地图数据

## 地图缓存字典
## 存储地图的临时状态和缓存数据，包含敌人刷新状态、环境变化、临时对象等
@export var map_cache = {}

## 地图信息字典
## 存储地图的层级结构和配置数据，包含关卡进度、解锁状态、传送点信息等
@export var level_info = {}

#endregion

#region 系统数据

## 黑板信息字典
## 存储全局共享的系统数据，包含任务状态、全局变量、剧情标记等
@export var blackboard_info = {}

#endregion
