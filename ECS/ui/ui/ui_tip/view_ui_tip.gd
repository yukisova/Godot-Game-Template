extends UIView

enum TipType{
	GET_ITEM = 0,
	LESSON
}
@onready var item_name: Label = %ItemName
@onready var item_description: RichTextLabel = %ItemDescription
@onready var item_texture: TextureRect = %ItemTexture
@onready var tab_container: TabContainer = $TabContainer

func _initialize(_context: Dictionary):
	var tip_type = _context.get("tip_type", -1)
	if tip_type == -1:
		controller.unspawn()
	match tip_type:
		TipType.GET_ITEM:
			tab_container.current_tab = tip_type
			var item: Item = _context.get("item")
			item_name.text = item.item_name
			item_description.text = item.item_description
			item_texture.texture = item.item_texture
			var button: Button = $TabContainer/GetItem/PanelContainer/VBoxContainer/Button
			button.pressed.connect(func(): controller.unspawn())
		TipType.LESSON:
			pass
	# 设置淡入动画效果
	modulate.a = 0
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
