extends Resource
class_name CraftingRecipe

@export var result_item: ItemIDs.ItemID
@export var result_count: int = 1

@export var ingredients: Dictionary[ItemIDs.ItemID, int] = {}
