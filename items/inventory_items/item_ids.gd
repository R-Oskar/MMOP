extends Node
class_name ItemIDs

enum ItemID {
	STONE,
	WOOD
}

const ITEM_REGISTRY := {
	ItemID.STONE: preload("res://items/inventory_items/blocks/stone.tres"),
	ItemID.WOOD: preload("res://items/inventory_items/blocks/wood.tres")
}

static func get_item(id: ItemID) -> Item:
	if ITEM_REGISTRY.has(id):
		return ITEM_REGISTRY[id].duplicate()
	return null
