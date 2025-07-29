##@editing:	Sora
##@describe:	FIXME 史莱姆法杖 没想好具体的实现方式
extends Resource

enum Mode{
	a = 0, ## 喷溅
	b, ## 爆破
	c, ## 散射
	d, ## 横甩
	e, ## 召唤
}

var current_mode: int = 0

func _change_mode(origin_context: Dictionary):
	var result = origin_context.duplicate()
	
