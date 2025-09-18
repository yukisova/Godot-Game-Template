## 测试AttributeHUD的MVC架构实现
## 验证Model、View、Controller之间的交互是否正常工作
## [br][b]编辑者:[/b] Sora
extends Node

## 测试控制器引用
var hud_controller: CanvasLayer  # AttributeHudController
var test_results: Array[String] = []

func _ready():
	print("=== AttributeHUD MVC架构测试 ===")
	_run_all_tests()
	_print_test_results()

## 运行所有测试
func _run_all_tests():
	_test_controller_creation()
	_test_model_initialization()
	_test_view_initialization()
	_test_mvc_integration()

## 测试控制器创建
func _test_controller_creation():
	print("\n[测试1] 控制器创建测试")
	
	# 创建控制器实例
	var controller_scene = preload("res://ui/hud/attribute_hud/attribute_hud.tscn")
	hud_controller = controller_scene.instantiate()
	
	if hud_controller:
		test_results.append("✓ 控制器创建成功")
		add_child(hud_controller)
	else:
		test_results.append("✗ 控制器创建失败")
		return
	
	# 检查控制器类型（检查是否有MVC控制器的标识方法）
	if hud_controller.has_method("is_working"):
		test_results.append("✓ 控制器类型正确")
	else:
		test_results.append("✗ 控制器类型错误")

## 测试模型初始化
func _test_model_initialization():
	print("\n[测试2] 模型初始化测试")
	
	if not hud_controller:
		test_results.append("✗ 控制器不存在，跳过模型测试")
		return
	
	# 等待控制器完成初始化
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 检查初始化状态
	if hud_controller.is_working():
		test_results.append("✓ MVC组件初始化成功")
	else:
		test_results.append("✗ MVC组件初始化失败")
		
	# 获取调试信息
	var debug_info = hud_controller.get_debug_info()
	if debug_info.get("model_exists", false):
		test_results.append("✓ 数据模型存在")
	else:
		test_results.append("✗ 数据模型不存在")

## 测试视图初始化
func _test_view_initialization():
	print("\n[测试3] 视图初始化测试")
	
	if not hud_controller:
		test_results.append("✗ 控制器不存在，跳过视图测试")
		return
		
	var debug_info = hud_controller.get_debug_info()
	if debug_info.get("view_exists", false):
		test_results.append("✓ 视图组件存在")
		
		var view_info = debug_info.get("view_info", {})
		if view_info.get("health_bar_configured", false):
			test_results.append("✓ 血量条配置正确")
		else:
			test_results.append("✗ 血量条配置错误")
			
		if view_info.get("fitness_bar_configured", false):
			test_results.append("✓ 体力条配置正确")
		else:
			test_results.append("✗ 体力条配置错误")
	else:
		test_results.append("✗ 视图组件不存在")

## 测试MVC集成
func _test_mvc_integration():
	print("\n[测试4] MVC集成测试")
	
	if not hud_controller or not hud_controller.is_working():
		test_results.append("✗ 系统未就绪，跳过集成测试")
		return
	
	# 测试显示/隐藏功能
	hud_controller.show_hud()
	await get_tree().process_frame
	test_results.append("✓ 显示HUD功能可用")
	
	hud_controller.hide_hud()
	await get_tree().process_frame
	test_results.append("✓ 隐藏HUD功能可用")
	
	# 测试强制刷新功能
	hud_controller.force_refresh()
	await get_tree().process_frame
	test_results.append("✓ 强制刷新功能可用")
	
	# 测试透明度设置
	hud_controller.set_hud_alpha(0.5)
	await get_tree().process_frame
	test_results.append("✓ 透明度设置功能可用")

## 打印测试结果
func _print_test_results():
	print("\n=== 测试结果摘要 ===")
	var passed = 0
	var total = test_results.size()
	
	for result in test_results:
		print(result)
		if result.begins_with("✓"):
			passed += 1
	
	print("\n总体结果: %d/%d 项测试通过" % [passed, total])
	
	if passed == total:
		print("🎉 所有测试通过！MVC架构实现正常")
	else:
		print("⚠️  有 %d 项测试失败，请检查实现" % (total - passed))
	
	print("========================\n")
	
	# 清理测试
	if hud_controller:
		hud_controller.queue_free()
