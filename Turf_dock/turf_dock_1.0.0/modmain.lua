-- env设置
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

PrefabFiles = {
    -- 载入预制体与placer建筑放置辅助工具
    "turf_dock",
    -- "dock_damage" --TODO 后续再做，延迟摧毁
}

Assets = {
    Asset("ATLAS", "images/inventoryimages/dock_kit/turf_dock.xml"), -- 导入资源
}

local turf_dock = Recipe("turf_dock", -- 预制体
        {
            Ingredient("log", 4),
            Ingredient("rocks", 4),
        },
        RECIPETABS.TOWN, -- 建筑栏
        TECH.NONE, -- 无科技
        RECIPE_GAME_TYPE.COMMON, -- 共用配方
        nil, -- placer
        nil,
        nil,
        4
)
turf_dock.atlas = "images/inventoryimages/dock_kit/turf_dock.xml" -- atlas资源必须与预制体一致

local function breakDockTurf(pt, radius)
    -- 计算起始和结束坐标
    local startX = math.floor(pt.x - radius)
    local startZ = math.floor(pt.z - radius)
    local endX = math.floor(pt.x + radius)
    local endZ = math.floor(pt.z + radius)

    -- 遍历范围内的坐标，并获取地皮类型
    for currentX = startX, endX do
        for currentZ = startZ, endZ do
            local tileType = GetMap():GetTileAtPoint(currentX, pt.y, currentZ)
            if (tileType == GROUND.MONKEY_DOCK) then
                -- 摧毁地皮
                print("----开始摧毁地皮，pt[" .. pt.x .. "," .. pt.y .. "," .. pt.z .. "]")
                BreakDockTurf(GROUND.OCEAN_SHALLOW, Vector3(currentX, pt.y, currentZ))
            end
        end
    end
end
-- 禁止草叉修改码头地皮
AddComponentPostInit("terraformer", function(inst)
    local _old = inst.CanTerraformPoint
    function inst:CanTerraformPoint(pt)
        local result = _old(inst, pt)
        local tile = GetMap():GetTileAtPoint(pt.x, pt.y, pt.z)
        return result and GROUND.MONKEY_DOCK ~= tile
    end
end)
-- 允许爆炸摧毁码头地皮
AddComponentPostInit("explosive", function(inst)
    local _old = inst.OnBurnt
    function inst:OnBurnt()
        _old(inst)
        local entity = inst.inst
        local pt = Vector3(entity.Transform:GetWorldPosition())
        breakDockTurf(pt, inst.explosiverange)
    end
end)
