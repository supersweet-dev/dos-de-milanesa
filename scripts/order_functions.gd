extends Node

const INGREDIENTS = GameData.ingredients

static func _count_ingredients(order: Array) -> Dictionary:
    var count = {}
    for ingredient in order:
        if ingredient in count:
            count[ingredient] += 1
        else:
            count[ingredient] = 1
    return count

static func _standard_order_check(target_order: Array, submitted_torta: Array, tip: int) -> int:
    var total_price = 0
    for ingredient in submitted_torta:
        if ingredient in INGREDIENTS.keys():
            total_price += INGREDIENTS[ingredient].price
    # Convert both arrays into dictionaries with ingredient counts
    var count1 = _count_ingredients(target_order)
    var count2 = _count_ingredients(submitted_torta)
    if (count1 == count2):
        return total_price + tip
    else:
        return -total_price

static func _mammoth_order_check(target_order: Array, submitted_torta: Array, tip: int) -> int:
    var total_price = 0
    for ingredient in submitted_torta:
        if ingredient in INGREDIENTS.keys():
            total_price += (INGREDIENTS[ingredient].price * 2)
    # Convert both arrays into dictionaries with ingredient counts
    var count1 = _count_ingredients(target_order)
    var count2 = _count_ingredients(submitted_torta)
    if (count1 == count2):
        return total_price + tip
    else:
        return -total_price

static func _xolo_order_check(target_order: Array, submitted_torta: Array, tip: int) -> int:
    var total_price = 0
    for ingredient in submitted_torta:
        if ingredient in INGREDIENTS:
            total_price += INGREDIENTS[ingredient].price

    var required_counts = _count_ingredients(target_order)
    var submitted_counts = _count_ingredients(submitted_torta)

    for ingredient in required_counts.keys():
        if not submitted_counts.has(ingredient):
            return -total_price # Missing required ingredient
        if submitted_counts[ingredient] < required_counts[ingredient]:
            return -total_price # Not enough of a required ingredient

    return total_price + tip # Passed all checks
