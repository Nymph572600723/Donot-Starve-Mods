-- env设置
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

-- 采集几率
local chance = GetModConfigData("RESOURCE_CHANCE")

local collection = {
    "cutgrass", -- 草
    "twigs", -- 树枝
    "log", -- 木头
    "flint", -- 燧石
    "rocks", -- 岩石
}

local function Select()
    local randomIndex = math.random(1, #collection)
    local randomElement = collection[randomIndex]
    return randomElement
end




-- 夜晚pickable组件是挂载在被采集物体上的，所以此self是表示pick这个component组件
local function ExtraResource(pickable)
    if pickable then
        local oldPick = pickable.Pick
        if oldPick then
            function pickable:Pick(picker)
                oldPick(pickable, picker)
                if picker and picker:HasTag("player") and (chance - math.random()) > 0 then
                    local sc = Select()
                    local item = SpawnPrefab(sc)
                    if item then
                        picker.components.inventory:GiveItem(item)
                    end
                end
            end
        end
    end
end

-- 监听实体创建事件
--AddPrefabPostInitAny(ExtraResource)
AddComponentPostInit("pickable", ExtraResource)
