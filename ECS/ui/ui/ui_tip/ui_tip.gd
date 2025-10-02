extends UIController

enum TipType{
	GET_ITEM,
}

func _initilize_info(_context: Dictionary):
	var tip_type = _context.get("tip_type", null)
	if tip_type != null:
		ui_view._initialize(_context)
	else:
		unspawn()
