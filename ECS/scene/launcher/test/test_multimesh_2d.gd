## MultiMeshInstance2D 测试与对比场景脚本
## 展示如何批量渲染实例，以及与逐个 MeshInstance2D 节点的区别
extends Node2D

@export var instance_count: int = 2000 ## 实例数量（建议 1k~10k 之间测试）
@export var spawn_margin: float = 32.0 ## 边缘留白，避免生成在屏外
@export var random_seed: int = 0 ## 固定随机种子，0 表示不设置
@export var primitive_size: float = 6.0 ## 形状尺寸（生成的 2D 矩形边长）

@onready var multi: MultiMeshInstance2D = $Multi
@onready var mesh_nodes: Node2D = $MeshNodes
@onready var info: Label = $Info

var _mesh: Mesh

func _ready() -> void:
	if random_seed != 0:
		seed(random_seed)
	_build_primitive_mesh()
	_build_multimesh()
	_build_mesh_nodes()
	_update_info()

func _process(_delta: float) -> void:
	_update_info()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F: ## 绑定到键盘 Delete（示例，可在项目设置中调整）
		_clear_all()
		return
	if event.is_action_pressed("ui_accept"): ## Enter/Space：重新生成
		_rebuild_all()
		return
	# 快捷键：1=仅 MultiMesh，2=仅 Mesh 节点，0=全部显示
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				multi.visible = true
				mesh_nodes.visible = false
				return
			KEY_2:
				multi.visible = false
				mesh_nodes.visible = true
				return
			KEY_0:
				multi.visible = true
				mesh_nodes.visible = true
				return

func _clear_all() -> void:
	# 清空 MultiMesh 与节点
	if multi.multimesh:
		multi.multimesh.instance_count = 0
	for c in mesh_nodes.get_children():
		c.queue_free()

func _rebuild_all() -> void:
	_clear_all()
	_build_primitive_mesh()
	_build_multimesh()
	_build_mesh_nodes()

func _build_primitive_mesh() -> void:
	# 使用 ArrayMesh 生成 2D 矩形（面朝屏幕），适用于 MeshInstance2D 与 MultiMeshInstance2D
	var half := primitive_size * 0.5
	var vertices := PackedVector2Array([
		Vector2(-half, -half),
		Vector2( half, -half),
		Vector2( half,  half),
		Vector2(-half,  half),
	])
	var uvs := PackedVector2Array([
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 2, 3])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mesh = am


func _build_multimesh() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	# 启用每实例颜色支持
	mm.use_colors = true
	mm.mesh = _mesh
	mm.instance_count = instance_count

	var size := get_viewport_rect().size
	var min_pos := Vector2(spawn_margin, spawn_margin)
	var max_pos := size - Vector2(spawn_margin, spawn_margin)

	for i in mm.instance_count:
		var p := Vector2(randf_range(min_pos.x, max_pos.x), randf_range(min_pos.y, max_pos.y))
		var rot := randf_range(0.0, TAU)
		var inst_scale := randf_range(0.6, 1.4)
		var xf := Transform2D(rot, p)
		xf.x *= inst_scale
		xf.y *= inst_scale
		mm.set_instance_transform_2d(i, xf)
		var hue := float(i) / maxf(1.0, float(mm.instance_count))
		mm.set_instance_color(i, Color.from_hsv(hue, 0.75, 0.95, 1.0))

	multi.multimesh = mm

func _build_mesh_nodes() -> void:
	# 用普通 MeshInstance2D 逐个生成对比（注意：节点过多会影响编辑器/运行性能）
	var size := get_viewport_rect().size
	var min_pos := Vector2(spawn_margin, spawn_margin)
	var max_pos := size - Vector2(spawn_margin, spawn_margin)

	for i in instance_count:
		var mi := MeshInstance2D.new()
		mi.mesh = _mesh
		mi.position = Vector2(randf_range(min_pos.x, max_pos.x), randf_range(min_pos.y, max_pos.y))
		mi.rotation = randf_range(0.0, TAU)
		mi.scale = Vector2.ONE * randf_range(0.6, 1.4)
		# 使用 Modulate 模拟每实例颜色（MultiMesh 有原生 per-instance color）
		var hue := float(i) / maxf(1.0, float(instance_count))
		mi.modulate = Color.from_hsv(hue, 0.75, 0.95, 1.0)
		mesh_nodes.add_child(mi)

func _update_info() -> void:
	var fps := int(Engine.get_frames_per_second())
	var mm_count := 0
	if multi.multimesh:
		mm_count = multi.multimesh.instance_count
	var node_count := mesh_nodes.get_child_count()
	info.text = "MultiMeshInstance2D: %d | MeshInstance2D 节点: %d | FPS: %d\n快捷键: 0=全部 1=仅Multi 2=仅Mesh  Enter=重建  Delete=清空" % [mm_count, node_count, fps]
