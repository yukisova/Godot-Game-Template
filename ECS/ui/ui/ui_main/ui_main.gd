extends UIController

## 主菜单设置
## 初始化音频、动画和按钮事件绑定
func _initilize_info(_context: Dictionary) -> void:
	ui_model._initialize({})
	ui_view._initialize({
		"controller": self
	})

	_bind_model_view()
