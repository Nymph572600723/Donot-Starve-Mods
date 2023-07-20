local item = Recipe("farm_plow_item", -- 预制体
        {
            -- 木板*3，绳索*2，燧石*2
            Ingredient("boards", 3), Ingredient("rope", 2), Ingredient("flint", 2)
        },
        RECIPETABS.FARM, -- 建筑栏，食物
        TECH.SCIENCE_TWO, -- 无科技，二本
        RECIPE_GAME_TYPE.COMMON -- 共用配方
)
item.atlas = "images/inventoryimages/inventoryimages1.xml"

local hoe= Recipe("farm_hoe",
        {
            Ingredient("rope", 1),
            Ingredient("twigs", 2),
            Ingredient("flint", 3),
        },
        RECIPETABS.TOOLS, TECH.SCIENCE_ONE)
hoe.atlas = "images/inventoryimages/ca_inventory_images.xml"

local hoe2= Recipe("farm_lux_hoe",
        {
            Ingredient("rope", 2),
            Ingredient("twigs", 4),
            Ingredient("goldnugget", 4),
        },
        RECIPETABS.TOOLS, TECH.SCIENCE_TWO)
hoe2.atlas = "images/inventoryimages/ca_inventory_images.xml"