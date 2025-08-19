## 融合记录 - 定义物品融合的规则和结果
## 该资源类定义了物品融合系统中的融合规则，包括原材料、催化剂和融合结果
## 用于配置复杂的物品合成和炼金系统
## 核心功能：定义融合所需的主要材料、指定融合催化剂或辅助材料、设置融合的最终产出物品
## 融合机制：双材料融合系统（主材料+催化剂）、基于字符串标识的材料匹配
## 应用场景：装备强化和升级、药水和消耗品制作、稀有物品的合成
## 架构设计：继承自 [Resource] 基类，基于字符串的材料标识系统，集成 [Item] 物品系统
## [br][b]编辑者:[/b] Sora
class_name FusionRecord
extends Resource

## 前置材料
## 融合所需的主要材料标识符，类型为 [String]
@export var material_pre: String

## 催化材料
## 融合所需的催化剂或辅助材料标识符，类型为 [String]
@export var material_pro: String

## 融合结果
## 成功融合后生成的物品，类型为 [Item]
@export var fusion_result: Item
