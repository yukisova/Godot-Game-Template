extends TextureRect
#
#func _ready():
	## 设置渐变图像的尺寸
	#var _size = Vector2(100, 100)
	#
	## 创建Image对象
	#var img = Image.new()
	#Image.create(_size.x, _size.y, false, Image.FORMAT_RGBA8)
	#img.fill(Color.WHITE)
	#
	## 遍历每个像素并设置渐变颜色
	#for x in range(_size.x):
		#for y in range(_size.y):
			## 计算插值比例（基于x坐标的水平渐变）
			#var ratio = float(x) / (_size.x - 1)
			## 使用lerp函数在黑和白之间插值
			#var color = lerp(Color.BLACK, Color.WHITE, ratio)
			#img.set_pixel(x, y, color)
	#
	## 创建ImageTexture并显示
	#texture = ImageTexture.create_from_image(img)
	#
