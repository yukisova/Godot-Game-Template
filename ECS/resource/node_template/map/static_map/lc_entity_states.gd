## 实体状态管理器
## 负责注册实体，以及根据实体的信息，调整实体的渲染，或者统一确认实体的状态
class_name LCEntityStates
extends LevelComponent

var hidding_entities: HiddingEntitiesSet = HiddingEntitiesSet.new()

@abstract class EntitiesSet:
	var entities: Array[IEntity]

	@abstract func append(entity: IEntity)
	@abstract func erase(entity: IEntity)

	@abstract func setup()
	@abstract func reset()

class HiddingEntitiesSet extends EntitiesSet:
	const HiddingShader: String = "res://resource/custom_resource/item/item_equipment/1_手电筒/手电筒遮罩.gdshader"
	var hidding_material: ShaderMaterial

	func append(entity: IEntity):
		if IEntity in entities:
			return
		var c_texture_controller = entity.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
		if c_texture_controller:
			c_texture_controller.packed_sprite.material = hidding_material
			entities.append(entity)
	
	func erase(entity: IEntity):
		if IEntity in entities:
			return
		var c_texture_controller = entity.get_other_component(IComponent.ComponentName.C_TEXTURE_CONTROLLER)
		if c_texture_controller:
			c_texture_controller.packed_sprite.material = null
			entities.erase(entity)

	func setup():
		hidding_material.set_shader_parameter("use_mask_texture", true)
	
	func reset():
		hidding_material.set_shader_parameter("use_mask_texture", false)
		
	func _init():
		if not ResourceLoader.exists(HiddingShader):
			print("HiddingShader not found")
			return

		hidding_material = ShaderMaterial.new()
		hidding_material.shader = load(HiddingShader)

var tilemap_layer_set: Dictionary[StringName, TileMapLayer]
var entity_sets: Dictionary[StringName, IEntity]

func _initialize():
	for i in get_parent().get_children():
		if i is TileMapLayer:
			tilemap_layer_set[i.name] = i
		elif i is IEntity:
			entity_sets[i.name] = i

func set_all_entity_visible(except_entity: Array[IEntity], _visible: bool):
	var target_color: Color
	var origin_color: Color
	if _visible:
		target_color = Color.WHITE
		origin_color = Color.TRANSPARENT
	else:
		target_color = Color.TRANSPARENT
		origin_color = Color.WHITE
	for i in entity_sets.values():
		if i in except_entity:
			i.modulate = origin_color
		else:
			i.modulate = target_color
	
func set_all_tilemap_layer_visible(except_layer: Array[TileMapLayer], _visible: bool):
	var target_color: Color
	var origin_color: Color
	if _visible:
		target_color = Color.WHITE
		origin_color = Color.TRANSPARENT
	else:
		target_color = Color.TRANSPARENT
		origin_color = Color.WHITE
	for i in tilemap_layer_set.values():
		if i in except_layer:
			i.modulate = origin_color
		else:
			i.modulate = target_color
	
	
