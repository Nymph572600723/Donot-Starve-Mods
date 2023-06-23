require "prefabutil"
require "map/water"

-- 判断是否水域
local function isWaterOrInvalid(ground)
    -- TODO 深海海域附件不允许使用
    return GetMap():IsWater(ground) or ground == GROUND.INVALID
end
-- 判断是否被水域包围，未被包围的就是海岸线
local function IsSurroundedByWaterOrInvalid(x, y, radius)
    for i = -radius, radius, 1 do
        if not isWaterOrInvalid(GetMap():GetTile(x - radius, y + i)) or not isWaterOrInvalid(GetMap():GetTile(x + radius, y + i)) then
            return false
        end
    end
    for i = -(radius - 1), radius - 1, 1 do
        if not isWaterOrInvalid(GetMap():GetTile(x + i, y - radius)) or not isWaterOrInvalid(GetMap():GetTile(x + i, y + radius)) then
            return false
        end
    end
    return true
end

local function flushShoreLine(tile_x, tile_y)
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            local X = tile_x + x
            local Y = tile_y + y
            local tile = GetMap():GetTile(X, Y)
            if GetMap():IsWater(tile) then
                if not IsSurroundedByWaterOrInvalid(X, Y, 1) then
                    if tile == GROUND.MANGROVE then
                        print("-----设置红树林海岸")
                        GetMap():SetTile(X, Y, GROUND.MANGROVE_SHORE)
                        GetMap():RebuildLayer(GROUND.MANGROVE_SHORE, X, Y)
                    elseif tile == GROUND.OCEAN_CORAL then
                        print("-----设置珊瑚礁海岸")
                        GetMap():SetTile(X, Y, GROUND.OCEAN_CORAL_SHORE)
                        GetMap():RebuildLayer(GROUND.OCEAN_CORAL_SHORE, X, Y)
                    else
                        print("-----设置普通海岸")
                        GetMap():SetTile(X, Y, GROUND.OCEAN_SHORE)
                        GetMap():RebuildLayer(GROUND.OCEAN_SHORE, X, Y)
                    end
                else
                    if tile == GROUND.MANGROVE_SHORE then
                        print("-----取消红树林海岸")
                        GetMap():SetTile(X, Y, GROUND.MANGROVE)
                        GetMap():RebuildLayer(GROUND.MANGROVE, X, Y)
                    elseif tile == GROUND.OCEAN_CORAL_SHORE then
                        print("-----取消珊瑚礁海岸")
                        GetMap():SetTile(X, Y, GROUND.OCEAN_CORAL)
                        GetMap():RebuildLayer(GROUND.OCEAN_CORAL, X, Y)
                    else
                        print("-----取消普通海岸")
                        GetMap():SetTile(X, Y, GROUND.OCEAN_SHALLOW)
                        GetMap():RebuildLayer(GROUND.OCEAN_SHALLOW, X, Y)
                    end
                end
            end
        end
    end
end

local function test_ground(inst, pt)
    -- GROUND.OCEAN_SHORE 海岸线
    -- GROUND.MANGROVE 红树林 GROUND.MANGROVE_SHORE 红树林海岸线
    -- GROUND.OCEAN_CORAL 珊瑚礁 GROUND.OCEAN_CORAL_SHORE 珊瑚礁海岸线
    -- GROUND.OCEAN_SHORE 一般海岸线
    local tile_type = GetMap():GetTileAtPoint(pt.x, pt.y, pt.z)
    if tile_type ~= GROUND.OCEAN_SHORE then
        return false
    end

    -- print("鼠标指向地块类型---------：" .. tile_type)
    local t_x, t_y = GetMap():GetTileCoordsAtPoint(pt.x, pt.y, pt.z)
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            if x ~= 0 and y ~= 0 then
                local X = t_x + x
                local Y = t_y + y
                local tile = GetMap():GetTile(X, Y)
                if tile == GROUND.OCEAN_MEDIUM or tile == GROUND.OCEAN_DEEP then
                    return false
                end
            end
        end
    end
    return true

end

local function ondeploy(inst, pt, deployer)
    local ground = GetWorld()
    local map = GetMap()

    local tile_type = map:GetTileAtPoint(pt.x, pt.y, pt.z) -- 获取地图地皮类型
    local x, y = map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z) -- 获取地图网格坐标

    if x and y then
        -- 设置地皮
        map:SetTile(x, y, inst.data.tile)

        -- 在指定位置重新生成地图图层
        ground.Map:RebuildLayer(tile_type, x, y)
        ground.Map:RebuildLayer(inst.data.tile, x, y)
    end

    local minimap = TheSim:FindFirstEntityWithTag("minimap")
    if minimap then
        -- 在小地图上重新生成图层
        minimap.MiniMap:RebuildLayer(tile_type, x, y)
        minimap.MiniMap:RebuildLayer(inst.data.tile, x, y)
    end

    -- 刷新边界线
    flushShoreLine(x, y)

    -- 需要实时刷新人物在船上和在陆地上可移动区域的烘焙范围，但目前没有找到烘焙的范围，只能通过小退生效
    --GetWorld():DoTaskInTime(5 * FRAMES, function(inst)
    --    -- print("---刷新空气墙---start")
    --    -- 销毁空气墙效果不起效，不能重新构建空气墙
    --    GetWorld():PushEvent("forcedestroy", { tags = { "NOBLOCK", "wall" } })
    --    -- print("---刷新空气墙---end")
    --end)

    inst.components.stackable:Get():Remove() -- 因为实体会销毁，所以不能使用inst:DoTaskInTime(Time,Function)
end

function BreakDockTurf(underTile, pt)
    local ground = GetWorld()
    local map = GetMap()

    local tile_type = map:GetTileAtPoint(pt.x, pt.y, pt.z) -- 获取地图地皮类型
    local x, y = map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z) -- 获取地图网格坐标

    local function breaks()
        if x and y then
            -- 设置地皮
            map:SetTile(x, y, underTile)

            -- 在指定位置重新生成地图图层
            ground.Map:RebuildLayer(tile_type, x, y)
            ground.Map:RebuildLayer(underTile, x, y)
        end

        local minimap = TheSim:FindFirstEntityWithTag("minimap")
        if minimap then
            -- 在小地图上重新生成图层
            minimap.MiniMap:RebuildLayer(tile_type, x, y)
            minimap.MiniMap:RebuildLayer(underTile, x, y)
        end
        -- 刷新边界线
        flushShoreLine(x, y)
    end
    --print("延迟摧毁测试-----1")
    --
    --local damage = SpawnPrefab("dock_damage")
    --damage.Transform:SetPosition(pt)
    --print("延迟摧毁测试-----4")
    --damage:DoTaskInTime(0.5, function(inst)
    --    inst.AnimState:PlayAnimation("idle2")
    --    print("延迟摧毁测试-----5")
    --end)
    --damage:DoTaskInTime(1.0, function(inst)
    --    print("延迟摧毁测试-----6")
    --    inst.AnimState:PlayAnimation("idle3")
    --end)
    --damage:DoTaskInTime(1.5, function(inst)
    --    print("延迟摧毁测试-----7")
    --    breaks()
    --    inst:Remove()
    --end)
    breaks()
end

local function make_turf(config)
    local name = config.name

    local assets = {
        Asset("ANIM", "anim/dock/dock_kit.zip"),
        Asset("ATLAS", "images/inventoryimages/dock_kit/turf_" .. name .. ".xml"),
        Asset("IMAGE", "images/inventoryimages/dock_kit/turf_" .. name .. ".tex"),
    }

    local prefabs = {
        "gridplacer",
        "surfboard_placer"
    }

    local function fn(Sim)

        local inst = CreateEntity()
        inst:AddTag("groundtile") -- 世界title标签
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(config.bank or "dock_kit")
        inst.AnimState:SetBuild(config.build or "dock_kit")
        inst.AnimState:PlayAnimation(config.anim or "idle", config.anim_back or false)

        MakeInventoryFloatable(inst, "idle", "idle")

        inst:AddComponent("stackable") -- 堆叠
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

        inst:AddComponent("inspectable") -- 可检查物品
        inst:AddComponent("inventoryitem") -- 可放入背包
        -- 纹理图集
        inst.components.inventoryitem.atlasname = "images/inventoryimages/dock_kit/turf_dock.xml"
        -- 表示使用图集中的哪个图片
        inst.components.inventoryitem.imagename = "turf_dock"

        inst.data = config

        inst:AddComponent("bait") -- 诱饵组件
        inst:AddTag("molebait") -- 诱饵标签

        inst:AddTag("groundtile") -- 地皮标签

        inst:AddComponent("fuel") -- 燃料组件
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL
        MakeMediumBurnable(inst, TUNING.MED_BURNTIME) -- 设置可燃性
        MakeSmallPropagator(inst) -- 设置火焰蔓延

        inst:AddComponent("deployable") -- 可部署or放置组件
        inst.components.deployable.ondeploy = ondeploy -- 放置后执行函数
        inst.components.deployable.test = test_ground -- 查看是否可以放置
        inst.components.deployable.min_spacing = 0 -- 放置间隔0
        inst.components.deployable.placer = "gridplacer" -- 辅助放置placer,上船的时候才能使用，因为海难在陆地上的时候船上会被识别为不可涉足的地块

        return inst
    end

    return Prefab("common/inventory/turf_" .. config.name, fn, assets, prefabs)
end

local turfs = {
    { name = "dock", tile = GROUND.MONKEY_DOCK } -- GROUND.JUNGLE丛林地皮，暂时先不自定义地皮，用丛林地皮代替
    --{ name = "dock", tile = GROUND.JUNGLE } -- GROUND.JUNGLE丛林地皮，暂时先不自定义地皮，用丛林地皮代替
}

STRINGS.NAMES.TURF_DOCK = "码头套件" -- 物品名称
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_DOCK = "最新科技" -- 物品检查说明
STRINGS.RECIPE_DESC.TURF_DOCK = "这个可靠么..." --制作栏说明

local prefabs = {}
for k, v in pairs(turfs) do
    table.insert(prefabs, make_turf(v))
end

return unpack(prefabs)
