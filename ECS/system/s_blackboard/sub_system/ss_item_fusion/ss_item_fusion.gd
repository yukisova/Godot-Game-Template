## 物品融合子系统 - 物品合成和融合功能管理
## 该子系统负责管理游戏中的物品融合和合成功能，提供基于配置的物品组合规则和合成结果管理
## 核心功能：物品融合规则的配置和管理、双向物品匹配的合成逻辑、融合结果的动态生成
## 主要特性：基于配置的融合规则系统、支持双向物品匹配（A+B = B+A）、动态物品复制和生成
## 使用场景：物品制作和合成系统、装备升级和强化、材料组合和转换、特殊物品的创造
## 架构设计：继承自 [ISubSystem] 基类，基于 [Array] of [FusionRecord] 的配置系统
## [br][b]TODO:[/b] 合成逻辑可能更适合放在物品内部，后续优化时可以考虑重构
## [br][b]编辑者:[/b] Sora
class_name SSItemFusion
extends ISubSystem

## 融合记录配置
## 存储所有物品融合规则的配置数组，类型为 [Array] of [FusionRecord]
@export var fusion_records: Array[FusionRecord]

## 设置子系统的关键字标识符
func _enter_tree() -> void:
	keyword = SubSystemType.ITEM_FUSION

## 当前不需要每帧更新，保留空实现
## [param _delta]: 帧时间间隔，类型为 [float]
func _update(_delta: float):
	pass

## 执行物品融合
## 
## 根据两个物品名称查找匹配的融合规则并返回结果物品。
## [param pre]: 第一个物品的名称，类型为 [String]
## [param pro]: 第二个物品的名称，类型为 [String]
## [br][br][b]返回:[/b] [Item] 融合结果物品，如果无匹配规则则返回null
func fusion_up(pre: String, pro: String) -> Item:
	for record in fusion_records:
		if record.material_pre == pre and record.material_pro == pro or record.material_pre == pro and record.material_pro == pre:
			return record.fusion_result.duplicate()
	return null

#region 存档系统

## 保存融合数据（重写方法）
## 
## 保存物品融合系统的状态数据。
## [param data]: 存档数据文件，类型为 [SavedDataFile]
## [br][br][b]返回:[/b] [Dictionary] 包含融合系统数据的字典
func _save_as(data: SavedDataFile):
	var result = {}
	return {
		keyword:result
	}

## 从存档文件加载物品融合系统状态
## [param data]: 存档数据文件，类型为 [SavedDataFile]
func _load_by(data: SavedDataFile):
	pass

#endregion
