extends Node
class_name ItemIDs

enum ItemID {
	STONE
}

const ITEM_REGISTRY := {
	ItemID.STONE: preload("res://items/blocks/Stone.tres"),
}
