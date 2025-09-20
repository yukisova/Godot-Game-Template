## 游戏主控制系统 - 管理玩家的输入信息逻辑与主要控制对象
## 负责玩家角色生成、定位、传送和伙伴管理等核心功能
## 支持多种移动模式并提供玩家输入的方向控制算法
## [br][b]编辑者:[/b] Sora
extends ISystem

enum PlayType {
	SINGLE = 0, ## 单人模式
	DOUBLE = 1, ## 双人模式
	THREE = 2, ## 三人模式
	FOUR = 3, ## 四人模式
}

enum DeviceType {
	COMPUTER, ## 电脑
	MOBILE, ## 移动端
	GAMEPAD, ## 游戏手柄
}

## 默认游戏模式
var play_type: PlayType = PlayType.SINGLE

## 玩家定位信号
## [param target_level]: 目标关卡
## [param _context]: 定位上下文信息
signal player_located(target_level: Level, _context: Dictionary)

## 伙伴加入信号
## [param _partner]: 加入的伙伴实体
signal partner_joined(_partner: IEntity)

## 玩家场景资源
## 用于实例化玩家角色的预制场景
@export var player_scene: Array[PackedScene]
var input_listener_list: Dictionary[PlayerRecordInfo, InputListener]
var player_static: Dictionary[PlayerRecordInfo, IEntity]

class PlayerRecordInfo extends Resource: 
	var player_scene_index: int = -1
	var player_scene_name: StringName
	
	func _init(_player_scene_index: int) -> void:
		player_scene_index = _player_scene_index


@export var partner: IEntity = null

func _enter_tree() -> void:
	set_process_unhandled_input(false)
		
func _process(_delta: float) -> void:
	for _input_listener in input_listener_list.values():
		_input_listener._listen()

func _setup():
	partner_joined.connect(func(_partner: IEntity):
		if partner:
			partner.queue_free()
		partner = _partner
	)
	player_located.connect(_on_player_located)
	
	await Launcher.main.system_setup_completed
	set_process_unhandled_input(true)

func _get_player_info_by_index(scene_index: int) -> IEntity:
	for i: PlayerRecordInfo in player_static.keys():
		if i.player_scene_index == scene_index:
			return player_static[i]
	return null

func _get_player_info_by_name(player_name: String) -> IEntity:
	for i: PlayerRecordInfo in player_static.keys():
		if i.player_scene_name == player_name:
			return player_static[i]
	return null

## 处理玩家定位信号的回调函数
## [param target_level]: 目标关卡
## [param _context]: 定位上下文信息
func _on_player_located(target_level: Level, _context: Dictionary):
	match _context.get("type", "Initialize"):
		"Initialize":
			## 无论是单人还是双人，player_static都可以用来作为判断的标准
			if (!player_static.is_empty()):
				var index: int = 0
				for player: IEntity in player_static.values():
					player.reparent(target_level)
					player.global_position = _context[index]["start_position"]
					player.main_control.global_position = _context[index]["current_position"]
			else:
				for i in play_type + 1:
					var player_context = _context.get(i, null)
					if player_context != null:
						var player_scene_path = player_context.get("scene_file_path",null)
						var player_record_info = PlayerRecordInfo.new(i)
						if player_scene_path != null:
							player_scene[i] = load(player_scene_path)
						player_static[player_record_info] = player_scene[i].instantiate()
						player_static[player_record_info].global_position = _context[i]["start_position"]
						player_static[player_record_info].main_control.global_position = _context[i]["current_position"]
						target_level.add_child(player_static[player_record_info])
						target_level.entity_count += 1
						
						player_static[player_record_info].initialize_complete.connect(func():
							target_level._on_entity_initialize()
							SUiSpawner.current_hud[&""].binding_entitys.append(player_static[player_record_info])
						)
		"Transport":
			if !player_static.is_empty():
				var target_point: TransportPoint = _context["target_point"]
				var start_position: Vector2 = target_point.global_position
				for player:IEntity in player_static.values():
					_context["target_level"].add_child(player)
					start_position += target_point.tranported_offset
					player.global_position = start_position
					player.main_control.global_position = start_position
			else:
				push_error("传送时未检测到玩家，请检查玩家配置")
				return
		_:
			push_error("未知的玩家初始化信息类型: %s" % _context.get("type", "Initialize"))
	
	SSignalBus.entity_initialize_started.emit()
	Main.entity_initialzable = true

#region 角色的主要移动方法(工具方法)

## 根据所需要获取的输入目标，对目标进行相关的映射
## [param entity: 角色实体]
## [br][br][b]返回:[/b] [SoraConstant.InputTarget] 输入目标
func get_input_target(entity: IEntity) -> SoraConstant.InputTarget:
	if entity == _get_player_info_by_index(0):
		return SoraConstant.InputTarget.PLAYER1
	elif entity == _get_player_info_by_index(1):
		return SoraConstant.InputTarget.PLAYER2
	elif entity == _get_player_info_by_index(2):
		return SoraConstant.InputTarget.PLAYER3
	elif entity == _get_player_info_by_index(3):
		return SoraConstant.InputTarget.PLAYER4
	else:
		return SoraConstant.InputTarget.COMMON

## 预留的双向移动控制方法
func _vec_input_2_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		SoraConstant.InputTarget.PLAYER3:
			prefix = "player3_"
		SoraConstant.InputTarget.PLAYER4:
			prefix = "player4_"
		_:
			return {}
	
	return {
		"vec": Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d").sign(),
		"pre_vec": Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d")
	}

## 处理四个方向的离散移动输入
## 优先级为：左→右→上→下
func _vec_input_4_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		SoraConstant.InputTarget.PLAYER3:
			prefix = "player3_"
		SoraConstant.InputTarget.PLAYER4:
			prefix = "player4_"
		_:
			return {}

	var vec_info : Dictionary = {}
	if Input.is_action_pressed(prefix + "move_l"):
		vec_info["vec"] = Vector2.LEFT
	elif Input.is_action_pressed(prefix + "move_r"):
		vec_info["vec"] = Vector2.RIGHT
	elif Input.is_action_pressed(prefix + "move_u"):
		vec_info["vec"] = Vector2.UP
	elif Input.is_action_pressed(prefix + "move_d"):
		vec_info["vec"] = Vector2.DOWN
	else:
		vec_info["vec"] = Vector2.ZERO
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 处理八个方向的离散移动输入
## 支持对角线移动，使用符号函数转换
func _vec_input_8_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		SoraConstant.InputTarget.PLAYER3:
			prefix = "player3_"
		SoraConstant.InputTarget.PLAYER4:
			prefix = "player4_"
		_:
			return {}
	var vec_info: Dictionary = {}
	vec_info["vec"] = Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d").sign()
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 处理连续的全方向移动输入
## 支持精确的模拟控制和部分移动
func _vec_input_a_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		SoraConstant.InputTarget.PLAYER3:
			prefix = "player3_"
		SoraConstant.InputTarget.PLAYER4:
			prefix = "player4_"
		_:
			return {}
	var vec_info : Dictionary = {}
	vec_info["vec"] = Input.get_vector(prefix + "move_l", prefix + "move_r", prefix + "move_u", prefix + "move_d")
	
	if (!vec_info["vec"].is_zero_approx()):
		vec_info["pre_vec"] = vec_info["vec"]
	return vec_info

## 根据鼠标点击的位置进行移动
## 类似moba游戏的操控方式
func _vec_input_m_toward(entity_input_target: SoraConstant.InputTarget) -> Dictionary:
	var vec_info: Dictionary = {}
	
	# 获取当前玩家实体
	var current_player: IEntity
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			current_player = _get_player_info_by_index(0)
		SoraConstant.InputTarget.PLAYER2:
			current_player = _get_player_info_by_index(1)
		SoraConstant.InputTarget.PLAYER3:
			current_player = _get_player_info_by_index(2)
		SoraConstant.InputTarget.PLAYER4:
			current_player = _get_player_info_by_index(3)
		_:
			# 默认使用玩家1
			current_player = _get_player_info_by_index(0)
	
	# 检查玩家是否存在
	if not current_player or not is_instance_valid(current_player):
		vec_info["vec"] = Vector2.ZERO
		return vec_info
	
	# 获取玩家当前位置
	var player_position = current_player.main_control.global_position
	
	# 获取鼠标在世界坐标系中的位置
	var mouse_world_position: Vector2
	
	# 获取对应的相机视口
	var camera_viewport = SViewportManager.get_viewport_container(current_player.main_control)
	if camera_viewport and camera_viewport.camera:
		# 获取视口中的鼠标位置
		var mouse_screen_position = camera_viewport.get_viewport_mouse_position()
		
		# 获取相机中心位置
		var camera_center = camera_viewport.camera.get_screen_center_position()
		
		# 计算鼠标在世界坐标系中的位置
		mouse_world_position = (mouse_screen_position - Vector2(camera_viewport.viewport.size)/2) + camera_center
	else:
		# 如果没有找到相机视口，使用视口鼠标位置
		mouse_world_position = get_viewport().get_mouse_position()
	
	# 计算从玩家到鼠标位置的方向向量
	var direction_vector = mouse_world_position - player_position
	
	# 检查是否有鼠标输入（左键点击）
	var prefix: String
	match entity_input_target:
		SoraConstant.InputTarget.PLAYER1:
			prefix = "player1_"
		SoraConstant.InputTarget.PLAYER2:
			prefix = "player2_"
		SoraConstant.InputTarget.PLAYER3:
			prefix = "player3_"
		SoraConstant.InputTarget.PLAYER4:
			prefix = "player4_"
		_:
			return {}
	
	# 检查是否按下主要动作键（通常是鼠标左键）
	var is_moving = Input.is_action_pressed(prefix + "movement")
	
	if is_moving and not direction_vector.is_zero_approx():
		# 标准化方向向量
		vec_info["vec"] = direction_vector.normalized()
		vec_info["pre_vec"] = vec_info["vec"]
	else:
		vec_info["vec"] = Vector2.ZERO
	
	return vec_info
#endregion


func create_listener_by_player(player: IEntity, input_component: CInputReactor):
	var new_listener = InputListener.new()
	new_listener.binding_input_component = input_component
	var player_record_info: PlayerRecordInfo = player_static.find_key(player)
	input_listener_list[player_record_info] = new_listener
