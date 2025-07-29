extends ISystem

signal map_info_loaded ## 游戏已经完成了地图数据信息的加载，下一步是初始化所有实体-> 刷新Hud状态
signal entity_initialize_started ## 玩家角色成功放入地图，可以正式开始初始化所有的实体
signal game_data_loaded_compelete ## 实体初始化完毕，已经可以正常开始游戏
