class_name SavedDataFile
extends Resource

var save_data = {}

## 玩家本身因为也是一个实体，所以应当与其他实体进行一定的区分
var player_info = {} ## 玩家的数据 (由s_main_control进行读取)


## 对于原本不存在于地图中的实体(如强制战斗，使用工厂生成的敌人，以及子弹实体)
## 对于原本存在于地图中的实体(如拥有指定对话的NPC，)
## 通过判断源文件是否存在场景项确定是否进行直接的获取
var static_entity = {} ## 原本就存在于地图中的实体

var blackboard_info = {} ## 黑板的信息 (由s_blackboard读取)

