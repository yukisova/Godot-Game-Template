## 高黏度凝胶
extends Projectile

var _speed: float = 600
var _velocity: Vector2
var max_range: float = 1000
var cur_range: float = 0

var shooter: Node2D 

@export var hitbox: Area2D

func _ready() -> void:
	hitbox.body_entered.connect(_on_body_entered)

func _fire(_position:Vector2, _direction:Vector2, _shooter: Node2D):
	global_position = _position;
	_velocity = _direction * _speed
	cur_range = 0
	shooter = _shooter

func _physics_process(delta: float) -> void:
	velocity += _velocity * delta
	cur_range += (_velocity * delta).length()
	if (cur_range > max_range):
		queue_free()
	move_and_slide()

func _on_body_entered(body: Node2D):
	if (body.get_parent() is Entity and body != shooter):
		var entity = body
		reparent.call_deferred(entity)
		var status_components = entity.list_base_components.filter(func(a): return a is C_Status)
		var status: C_Status
		if (status_components.size() > 0):
			status = status_components[0]
			#status.buff_list.
			queue_free()
		else:
			queue_free()
			return
		get_tree().create_timer(5).timeout.connect(queue_free)
	else:
		#queue_free.call_deferred()
		pass
