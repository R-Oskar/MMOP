extends Node
class_name ItemIDs

enum ItemID {
	STONE
}

const ITEM_REGISTRY := {
	ItemID.STONE: preload("res://items/blocks/Stone.tres"),
}

static func get_item(id: ItemID) -> Item:
	if ITEM_REGISTRY.has(id):
		return ITEM_REGISTRY[id].duplicate()
	return null
