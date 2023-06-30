local AddRecipe2 = AddRecipe2
GLOBAL.setfenv(1, GLOBAL)

local function SortRecipe(a, b, filter_name, offset)
    local filter = CRAFTING_FILTERS[filter_name]
    if filter and filter.recipes then
        for sortvalue, product in ipairs(filter.recipes) do
            if product == a then
                table.remove(filter.recipes, sortvalue)
                break
            end
        end

        local target_position = #filter.recipes + 1
        for sortvalue, product in ipairs(filter.recipes) do
            if product == b then
                target_position = sortvalue + offset
                break
            end
        end

        table.insert(filter.recipes, target_position, a)
    end
end

local function SortBefore(a, b, filter_name)
    SortRecipe(a, b, filter_name, 0)
end

local function SortAfter(a, b, filter_name)
    SortRecipe(a, b, filter_name, 1)
end

-- 制作所需要的材料
local Ingredients = {Ingredient("dreadstone", 4), Ingredient("horrorfuel", 4)}

AddRecipe2("dreadsword", Ingredients, TECH.LOST, {nounlock = false}, {"MAGIC", "WEAPONS"})
SortBefore("dreadsword", "nightsword", "MAGIC")
SortAfter("dreadsword", "nightstick", "WEAPONS")
