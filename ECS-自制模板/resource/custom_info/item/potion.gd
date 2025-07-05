## 药品
extends Item

func _use():
	print("这是装在玻璃容器里的药品，既可以自己使用，也可以丢向敌人")

func _throw():
	print("你丢出了这个药品")
