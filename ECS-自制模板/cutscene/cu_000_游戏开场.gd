##@editing:	Sora
##@describe:	测试用, 游戏入场的脚本, 基于Tween节点
extends Cutscene

## 在进入GamingNormal状态时自动调用
func _start(_context: Dictionary):
	#if cutscene_dependencies_check(["洞穴滤镜"], _context):
		#return
	#
	#过场1_玩家苏醒(_context)
	pass

## 入场之后，先要进行基础故事开场的说明
func 过场1_玩家苏醒(_context: Dictionary):
	## 镜头一，询问玩家控制信息
	## 1. 视角缩小，
	var player = SPlayerStatic.player_static
	var c_camera = player.list_base_components[IComponent.ComponentName.c_camera] as C_Camera
	c_camera.camera.zoom = Vector2(5,5) ## 对视野进行缩小
	
	## 2. 黑色场景_需要使用滤镜之类
	var canvas_modulate = _context["洞穴滤镜"] as CanvasModulate
	canvas_modulate.color = Color(0.1,0.1,0.1)
	
	## 3. 出现对话框，样式需要慢慢调整，但是效果可以正常
	## 喂, 醒一醒，再不醒你就没命了！
	## 这里被外来者攻陷了，让你有意识已经是长老他们所能做到的极限了
	## 我是……可恶，来不及了，现在先不能管这么多了！先确认一下你的状况吧
	## 
	
