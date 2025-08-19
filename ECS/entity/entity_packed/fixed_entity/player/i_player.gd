## 玩家实体接口 - 玩家角色的特殊实体实现
## 该类继承自FixedEntity，专门为玩家角色提供特殊的实体逻辑，重写了存档系统的相关方法，确保玩家数据能正确保存到主控制器中
## 核心功能：专门的玩家数据存档逻辑、与主控制器系统的集成、玩家位置和状态的特殊处理、组件数据的统一管理
## 主要特性：重写存档方法以适配玩家数据结构、支持初始化和位置恢复的双重模式、集成所有基础组件和接口组件的数据
## 存档结构：player_info包含玩家的基本信息和位置、scene_file_path玩家角色的场景文件路径、start_position玩家的起始位置、current_position玩家的当前位置、components所有组件的存档数据
## 架构设计：继承自FixedEntity基类，使用@tool支持编辑器功能，集成SavedDataFile的专用存档接口，与SMainController的玩家管理系统集成
## [br][b]编辑者:[/b] Sora
@tool
extends FixedEntity

## 保存玩家数据—将玩家的位置、场景和组件数据保存到专用的玩家信息结构中
## [param data]: 存档数据文件
func _save_as(data: SavedDataFile) -> Dictionary:
	data.player_info = {
		"type": "Initialize", ## 在传入player_located时，表明是初始化，逻辑会有所不同
		"scene_file_path":scene_file_path, ## 有可能角色不一样
		"start_position":global_position,
		"current_position":main_control.global_position,
	}
	var components = {}
	for base_component:IComponent in list_base_components.values():
		components.merge(base_component._save())
	for interface_component:IComponent in list_interface_components.values():
		components.merge(interface_component._save())
	data.player_info["components"] = components

	return {}


## 加载玩家数据—从存档数据中加载玩家信息，位置和状态由主控制器处理
## [param data]: 存档数据文件
func _load_by(data: SavedDataFile) -> Dictionary:
	var player_info = data.player_info
	## 这里不进行任何操作，因为玩家的位置和状态已经在s_main_controller中进行处理了
	
	return data.player_info.get("components", {})
