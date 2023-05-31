-- env设置
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

PrefabFiles = {
    "kafka"
}

-- twigs 树枝

--让不可入锅的材料入锅
AddIngredientValues({ "log" }, { -- 木头
    inedible = 1 -- inedible：不可食用的
})
AddIngredientValues({ "cutgrass" }, { -- 草
    inedible = 1 -- inedible：不可食用的
})
AddIngredientValues({ "rocks" }, { -- 石头
    inedible = 1 -- inedible：不可食用的
})

--添加食谱
local kafka = {
    -- tags.egg蛋类，tags.veggie蔬菜类，tags.fruit水果类，tags.meat肉类，tags.inedible不可食用类
    test = function(cooker, names, tags)
        --配方，木头*1，石头*1，树枝*1，草*1
        return names.log == 1 and names.cutgrass == 1 and names.rocks == 1 and names.twigs == 1
    end,
    name = "kafka",
    weight = 1, -- 食谱权重，必须设置
    priority = 10, -- 食谱优先级 -1~10
    foodtype = "GENERIC", -- 食物类型，通用
    health = 0,
    hunger = 0,
    sanity = 0,
    perishtime = TUNING.PERISH_PRESERVED, -- 保质期，表示永不过期
    cooktime = 0.25, -- 烹饪时间，1单位等于20s左右
}

AddCookerRecipe("cookpot", kafka) -- 添加到普通锅
AddCookerRecipe("portablecookpot", kafka) -- 添加到便携烹饪锅

-- 设置物品说明
STRINGS.NAMES.KAFKA = "Kafka罐头"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KAFKA = "嗯？确实是罐头！"