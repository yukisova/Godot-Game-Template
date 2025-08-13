## @editing: Sora [br]
## @describe: 网格背包测试场景 - 用于验证网格背包系统的功能
##
## 该测试场景提供了网格背包系统的完整功能测试：
## - 添加不同类型的测试物品
## - 测试自动整理功能
## - 测试清空背包功能
## - 测试物品旋转功能
## - 提供用户交互指导
##
## 测试项目：
## - 物品添加和放置
## - 拖拽和旋转操作
## - 预览功能验证
## - 自动整理算法
## - 边界情况处理
extends Control

#region 场景节点引用

## 网格背包组件
@onready var grid_inventory: GridInventory = $GridInventory

## 测试控制按钮
@onready var add_item_button: Button = $TestControls/AddItemButton
@onready var auto_organize_button: Button = $TestControls/AutoOrganizeButton
@onready var clear_button: Button = $TestControls/ClearButton

#endregion

#region 测试数据

## 测试物品列表
## 包含不同尺寸和类型的物品用于测试
var test_items: Array[Item] = []

#endregion

#region 场景初始化

## 场景准备就绪
## 初始化测试环境和连接信号
func _ready():
	print("网格背包测试: 开始初始化")
	
	# 连接按钮信号
	add_item_button.pressed.connect(_on_add_item_pressed)
	auto_organize_button.pressed.connect(_on_auto_organize_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	
	# 创建测试物品
	_create_test_items()
	
	print("网格背包测试: 初始化完成")

#endregion

#region 测试物品创建

## 创建测试物品
## 生成各种尺寸和类型的物品用于测试
func _create_test_items():
	print("网格背包测试: 创建测试物品")
	
	# 创建1x1物品
	var small_item = Item.new()
	small_item.item_name = "小物品"
	small_item.item_description = "这是一个1x1的小物品"
	small_item.item_tilesize = Vector2i(1, 1)
	small_item.item_weight = 1.0
	# 创建简单的纹理（这里使用颜色块）
	var small_texture = _create_color_texture(Color.BLUE, 80, 80)
	small_item.item_texture = small_texture
	test_items.append(small_item)
	
	# 创建2x1物品
	var medium_item = Item.new()
	medium_item.item_name = "中等物品"
	medium_item.item_description = "这是一个2x1的中等物品"
	medium_item.item_tilesize = Vector2i(2, 1)
	medium_item.item_weight = 2.0
	var medium_texture = _create_color_texture(Color.GREEN, 160, 80)
	medium_item.item_texture = medium_texture
	test_items.append(medium_item)
	
	# 创建2x2物品
	var large_item = Item.new()
	large_item.item_name = "大物品"
	large_item.item_description = "这是一个2x2的大物品"
	large_item.item_tilesize = Vector2i(2, 2)
	large_item.item_weight = 4.0
	var large_texture = _create_color_texture(Color.RED, 160, 160)
	large_item.item_texture = large_texture
	test_items.append(large_item)
	
	# 创建1x3物品
	var long_item = Item.new()
	long_item.item_name = "长物品"
	long_item.item_description = "这是一个1x3的长物品"
	long_item.item_tilesize = Vector2i(1, 3)
	long_item.item_weight = 3.0
	var long_texture = _create_color_texture(Color.YELLOW, 80, 240)
	long_item.item_texture = long_texture
	test_items.append(long_item)
	
	print("网格背包测试: 创建了 ", test_items.size(), " 个测试物品")

## 创建颜色纹理
## 用于测试的简单颜色块纹理
## @param color: 纹理颜色
## @param width: 纹理宽度
## @param height: 纹理高度
## @return: 生成的纹理对象
func _create_color_texture(color: Color, width: int, height: int) -> Texture2D:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

#endregion

#region 按钮事件处理

## 添加物品按钮事件
## 随机添加一个测试物品到背包
func _on_add_item_pressed():
	if test_items.is_empty():
		print("网格背包测试: 没有可用的测试物品")
		return
	
	# 随机选择一个测试物品
	var random_index = randi() % test_items.size()
	var selected_item = test_items[random_index]
	
	print("网格背包测试: 尝试添加物品 ", selected_item.item_name)
	
	# 尝试添加到背包
	var success = await grid_inventory.add_item(selected_item)
	if success:
		print("网格背包测试: 成功添加物品 ", selected_item.item_name)
	else:
		print("网格背包测试: 添加物品失败，背包可能已满")

## 自动整理按钮事件
## 触发背包的自动整理功能
func _on_auto_organize_pressed():
	print("网格背包测试: 开始自动整理")
	grid_inventory.auto_organize()
	print("网格背包测试: 自动整理完成")

## 清空背包按钮事件
## 清空背包中的所有物品
func _on_clear_pressed():
	print("网格背包测试: 清空背包")
	
	# 获取所有物品并移除
	var items_to_remove = grid_inventory.items_in_inventory.duplicate()
	for item in items_to_remove:
		grid_inventory.remove_item(item)
		item.queue_free()
	
	print("网格背包测试: 背包已清空")

#endregion

#region 输入处理

## 处理键盘输入
## 提供额外的测试功能
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1:
				# 快速添加小物品
				if test_items.size() > 0:
					await grid_inventory.add_item(test_items[0])
			KEY_2:
				# 快速添加中等物品
				if test_items.size() > 1:
					await grid_inventory.add_item(test_items[1])
			KEY_3:
				# 快速添加大物品
				if test_items.size() > 2:
					await grid_inventory.add_item(test_items[2])
			KEY_4:
				# 快速添加长物品
				if test_items.size() > 3:
					await grid_inventory.add_item(test_items[3])
			KEY_0:
				# 快速清空背包
				_on_clear_pressed()

#endregion
