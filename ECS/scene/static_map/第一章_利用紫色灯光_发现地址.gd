## 新游戏开场剧情，主角在开始游戏之后会逐步将视角移至中心角色中心
@tool
extends CutsceneNode

@export var dialogue_resource: DialogueResource
@export var interaction_transport: InteractionTransport

func _start() -> String:
	var entity: IEntity = cutscene_context.get("entity", null)
	if not entity:
		push_error("本剧情需要传入参数entity，才可以正常运行")
		return super()
	var c_status_list: CStatusList = entity.get_other_component(IComponent.ComponentName.C_STATUS_LIST)
	var inventory: InventoryExtension = c_status_list.get_status_extension(StatusExtension.ExtensionType.INVENTORY)
	var documents = inventory.inventory_array_document.map(func(v: ItemDocument): return v.item_nick_name)

	if "mom_note_0" in documents:
		await start_caption(dialogue_resource, "caption_发现妈妈的隐藏字迹", {})
		cutscene_context.set("have_note", true)
		var hud_transition = SUiSpawner._get_hud("transition")
		hud_transition.try_show()
		await hud_transition.fade_out()
		interaction_transport.interact_activated.emit(entity)
		hud_transition.fade_in()
	else:
		await start_caption(dialogue_resource, "caption_没有发现妈妈留言的情况下", {})
		cutscene_context.set("have_note", false)
		
	return super()

func _return() -> Dictionary:
	var result = cutscene_context.get("have_note", false)
	return {"END": result}
