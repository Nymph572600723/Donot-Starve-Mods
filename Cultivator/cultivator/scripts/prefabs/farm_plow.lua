-- 耕地机
require "prefabutil"
local constant_turfs = require "constant_turfs"

local assets = {
    Asset("ANIM", "anim/farm_plow.zip"),
    Asset("ANIM", "anim/farm_soil.zip"),
    Asset("ATLAS", "images/inventoryimages/inventoryimages.xml"),
    Asset("IMAGE", "images/inventoryimages/inventoryimages.tex"),
    Asset("ATLAS", "images/inventoryimages/inventoryimages1.xml"),
    Asset("IMAGE", "images/inventoryimages/inventoryimages1.tex"),
    Asset("ATLAS", "images/inventoryimages/inventoryimages2.xml"),
    Asset("IMAGE", "images/inventoryimages/inventoryimages2.tex"),
    Asset("ATLAS", "images/inventoryimages/inventoryimages3.xml"),
    Asset("IMAGE", "images/inventoryimages/inventoryimages3.tex"),
}

local assets_item = {
    Asset("ANIM", "anim/farm_plow.zip"),
    Asset("ATLAS", "images/inventoryimages/inventoryimages1.xml"),
    Asset("IMAGE", "images/inventoryimages/inventoryimages1.tex"),
}

local prefabs = {
    "farm_soil_debris",
    "farm_soil",
    "smoke_puff", -- 联机灰尘特效
    -- turfs
    "turf_rocky", "turf_road", "turf_dirt", "turf_savanna",
    "turf_grass", "turf_forest", "turf_marsh", "turf_woodfloor",
    "turf_carpetfloor", "turf_checkerfloor", "turf_cave", "turf_fungus",
    "turf_fungus_red", "turf_fungus_green", "turf_sinkhole", "turf_underrock",
    "turf_mud", "turf_desertdirt", "turf_deciduous", "turf_beach",
    "turf_jungle", "turf_swamp", "turf_magmafield", "turf_tidalmarsh",
    "turf_meadow", "turf_volcano", "turf_ash", "turf_snakeskinfloor",
    "cutstone", "cutstone", "turf_rainforest", "turf_deeprainforest",
    "turf_gasjungle", "turf_moss", "turf_fields", "turf_foundation",
    "turf_cobbleroad", "turf_lawn", "turf_beard_hair", "turf_plains",
    "turf_painted", "turf_deeprainforest_nocanopy", "turf_webbing",
}

local prefabs_item = {
    "farm_plow",
    "farm_plow_item_placer",
    -- "tile_outline", -- 联机标记预制体
}

-- 判断地皮是否适合耕种
local function CanTillSoilAtPoint(x, y, z)
    local tile = GetMap():GetTileAtPoint(x, y, z)
    if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
        if tile == GROUND.ASH or tile == GROUND.VOLCANO
                or tile == GROUND.VOLCANO_ROCK or tile == GROUND.BRICK_GLOW
                or tile == GROUND.VOLCANO_LAVA or tile == GROUND.SNAKESKIN
        -- or tile == GROUND.BEACH -- 海难的海滩允许沙滩进行耕种
        then
            return false
        end
    end
    if IsDLCEnabled(PORKLAND_DLC) then
        if tile == GROUND.FOUNDATION or tile == GROUND.COBBLEROAD
                or tile == GROUND.GASJUNGLE or tile == GROUND.PIGRUINS or tile == GROUND.DEEPRAINFOREST
                or tile == GROUND.PIGRUINS_NOCANOPY or tile == GROUND.BEARDRUG or tile == GROUND.INTERIOR
        then
            return false
        end
    end
    if tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= GROUND.ROCKY and tile ~= GROUND.ROAD
            and tile ~= GROUND.UNDERROCK and tile ~= GROUND.WOODFLOOR and tile ~= GROUND.CARPET and tile ~= GROUND.CHECKER
            and tile ~= GROUND.DIRT and tile < GROUND.UNDERGROUND
    then
        return true
    end
    return false
end

local function GetDistanceSqToPoint(inst, x, y, z)
    if y == nil and z == nil and x ~= nil then
        x, y, z = x:Get()
    end
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    return distsq(x, z, x1, z1)
end

local FIND_SOIL_MUST_TAGS = { "soil" }
function CollapseSoilAtPoint(x, y, z)
    local till_spacing = TUNING.FARM.TILL_SPACING or 1
    for i, v in ipairs(TheSim:FindEntities(x, y, z, till_spacing, FIND_SOIL_MUST_TAGS)) do
        if v and v.is_plant then
            return false
        end
        v:PushEvent(GetDistanceSqToPoint(v, x, y, z) < till_spacing * 0.5 and "collapsesoil" or "breaksoil")
    end
    return true
end

local function onhammered(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)

    if inst.deploy_item_save_record ~= nil then
        local item = SpawnSaveRecord(inst.deploy_item_save_record)
        item.Transform:SetPosition(x, y, z)
    end
    inst:Remove()
end

local function dirt_anim(inst, quad, timer)
    -- 做出土块飞溅的效果来   已完成
    local x, y, z = inst.Transform:GetWorldPosition()
    local padding = 0.5
    local offset_x = math.random()
    local offset_z = math.random()
    offset_x = (1 - offset_x * offset_x) * 2
    offset_z = (1 - offset_z * offset_z) * 2
    if quad == 1 then
        -- 反转X，Z
        offset_x = -offset_x
        offset_z = -offset_z
    elseif quad == 2 then
        -- 反转Z
        offset_z = -offset_z
    elseif quad == 3 then
        -- 反转X
        offset_x = -offset_x
    end
    if offset_x * offset_x + offset_z * offset_z > 0.75 * 0.75 then
        local _x, _z = x + offset_x, z + offset_z
        if CanTillSoilAtPoint(_x, 0, _z) and CollapseSoilAtPoint(_x, 0, _z) then
            local soil = SpawnPrefab("farm_soil")
            soil.Transform:SetPosition(_x, 0, _z)
            if soil.SetPlowing ~= nil then
                soil:SetPlowing(inst) -- Plowing 添加土壤塌陷检测与耕地机完毕后保持状态
            end
        end
    end

    local t = math.min(1, timer / 15)
    local duration_delay = Lerp(1.5, 2.0, t)
    local delay = duration_delay + math.random() * 0.3

    inst:DoTaskInTime(delay, dirt_anim, quad, timer + delay)
end

local function DoDrilling(inst)
    inst:RemoveEventCallback("animover", DoDrilling)

    inst.AnimState:PlayAnimation("drill_loop", true)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/LP", "loop")
    local fx_time = 0
    if not inst.components.timer:TimerExists("drilling") then
        inst.components.timer:StartTimer("drilling", 30 * 0.5)
    else
        fx_time = 30 * 0.5 - inst.components.timer:GetTimeLeft("drilling")
    end

    -- 用来设置soil生成
    inst:DoTaskInTime(math.random() * 0.2, dirt_anim, 1, fx_time)
    inst:DoTaskInTime(0.2 + math.random() * 0.3, dirt_anim, 2, fx_time)
    inst:DoTaskInTime(1.0 + math.random() * 0.5, dirt_anim, 3, fx_time)
    inst:DoTaskInTime(0.5 + math.random() * 0.3, dirt_anim, 4, fx_time)
end

local function item_foldup_finished(inst)
    if inst then
        inst:RemoveEventCallback("animover", item_foldup_finished)
        inst.AnimState:PlayAnimation("idle_packed")
        inst.components.inventoryitem.canbepickedup = true --可被拾取
    end
end

local function Finished(inst, force_fx)
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.deploy_item_save_record ~= nil then
        local item = SpawnSaveRecord(inst.deploy_item_save_record)
        if item then
            item.Transform:SetPosition(x, y, z)
            item.components.inventoryitem.canbepickedup = false -- 不可被拾取
            item.AnimState:PlayAnimation("collapse", false)
            item:ListenForEvent("animover", item_foldup_finished)

            item.SoundEmitter:PlaySound("farming/common/farm/plow/collapse")
            SpawnPrefab("smoke_puff").Transform:SetPosition(x, y, z)
            item.SoundEmitter:PlaySound("farming/common/farm/plow/dirt_puff")
        end
    else
        SpawnPrefab("smoke_puff").Transform:SetPosition(x, y, z)
    end

    inst:PushEvent("finishplowing")
    inst:Remove()
end

-- 在挖地皮的时候生成地皮物件，如果为基础地皮就不生成
local function SpawnTurf(tile, _pt,_old_tile)
    local x, y, z = GetMap():GetTileCenterPoint(_pt:Get())
    -- 判断当前世界基础tile
    local basetile = GROUND.DIRT
    if GetWorld():HasTag("shipwrecked") then
        basetile = GROUND.BEACH
    elseif GetWorld():HasTag("volcano") then
        basetile = GROUND.VOLCANO_ROCK
    elseif _old_tile == GROUND.PIGRUINS then
        basetile = GROUND.DEEPRAINFOREST
    end

    local turf = constant_turfs.GROUND_TURFS[tile] -- 获取tile对应turf地皮
    if turf and basetile ~= tile then
        local loot = SpawnPrefab(turf)
        loot.Transform:SetPosition(x, y, z)
        if loot.Physics then
            local angle = math.random() * 2 * PI
            loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))
        end
    end
end

local function changeTile(inst, _pt, tile_type)
    if not tile_type then
        tile_type = GROUND.FARMING_SOIL
    end

    local old_tile_type = GetMap():GetTileAtPoint(_pt:Get()) -- 获取地图地皮类型
    local x, y = GetMap():GetTileCoordsAtPoint(_pt:Get()) -- 获取地图网格坐标

    if x and y then
        -- 设置地皮
        GetMap():SetTile(x, y, tile_type)

        -- 在指定位置重新生成地图图层
        GetMap():RebuildLayer(old_tile_type, x, y)
        GetMap():RebuildLayer(tile_type, x, y)
    end

    local minimap = TheSim:FindFirstEntityWithTag("minimap")
    if minimap then
        -- 在小地图上重新生成图层
        minimap.MiniMap:RebuildLayer(old_tile_type, x, y)
        minimap.MiniMap:RebuildLayer(tile_type, x, y)
    end

    SpawnTurf(old_tile_type, _pt,old_tile_type)
end

local function VecUtil_DistSq(p1_x, p1_z, p2_x, p2_z)
    return (p1_x - p2_x) * (p1_x - p2_x) + (p1_z - p2_z) * (p1_z - p2_z)
end

local function IsPosWithin(x, z, positions, dist)
    dist = dist * dist
    for i, v in ipairs(positions) do
        local distance = VecUtil_DistSq(x, z, v.x, v.z)
        if distance < dist then
            return true
        end
    end
    return false
end

local function OnTerraform(inst, _pt, old_tile_type, old_tile_turf_prefab)
    -- spawn some farm_soil_debris and farm_soil
    if not _pt then
        _pt = inst:GetPosition()
    end

    -- 在此生成农田杂物
    --已完成
    local cx, cy, cz = GetMap():GetTileCenterPoint(_pt:Get())
    local TILE_EXTENTS = TILE_SCALE * 0.9
    local spawned_positions = {}
    for i = 1, math.random(2, 4) do
        local x = cx + (math.random() * TILE_EXTENTS) - TILE_EXTENTS / 2
        local z = cz + (math.random() * TILE_EXTENTS) - TILE_EXTENTS / 2
        if not IsPosWithin(x, z, spawned_positions, 1) then
            -- 限制一定范围内不会重复出现杂物
            table.insert(spawned_positions, { x = x, z = z })
            CollapseSoilAtPoint(x, cy, z) -- 让周围的土地塌陷（向周围的土块发送破坏或者塌陷事件）
            SpawnPrefab("farm_soil_debris").Transform:SetPosition(x, cy, z)
        end
    end

    SpawnPrefab("smoke_puff").Transform:SetPosition(cx + math.random() + 1, cy, cz + math.random() + 1)
    SpawnPrefab("smoke_puff").Transform:SetPosition(cx - math.random() - 1, cy, cz + math.random() + 1)
    SpawnPrefab("smoke_puff").Transform:SetPosition(cx + math.random() + 1, cy, cz - math.random() - 1)
    SpawnPrefab("smoke_puff").Transform:SetPosition(cx - math.random() - 1, cy, cz - math.random() - 1)

    -- 修改地皮
    changeTile(inst, _pt, GROUND.FARMING_SOIL)
    Finished(inst)
end

local function timerdone(inst, data)
    if data ~= nil and data.name == "drilling" then
        OnTerraform(inst)
        -- Finished(inst)
    end
end

local function item_ondeploy(inst, pt, deployer, rot)
    -- rot 物体旋转的度数，角度或者弧度
    local cx, cy, cz = GetMap():GetTileCenterPoint(pt:Get())
    local obj = SpawnPrefab("farm_plow")
    obj.Transform:SetPosition(cx, cy, cz)
    inst.components.finiteuses:Use(1)
    if inst:IsValid() then
        obj.deploy_item_save_record = inst:GetSaveRecord() -- 存储item
        inst:Remove()
    end
end

local function test_ground(inst, pt)
    local notags = { 'NOBLOCK', -- 无物理阻挡的
                     'player', -- 玩家
                     'shadowcreature', -- 排除影怪
                     'FX' -- 特效
    }
    local ptX, ptY, ptZ = GetMap():GetTileCenterPoint(pt:Get())

    local tile_x, tile_y = GetMap():GetTileCoordsAtPoint(ptX, ptY, ptZ) -- 获取地图网格坐标
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            local X = tile_x + x
            local Y = tile_y + y
            local tile = GetMap():GetTile(X, Y)
            if GetWorld().Map:IsWater(tile) or tile == GROUND.IMPASSABLE then
                return false
            end
        end
    end

    local ground_OK = inst:GetIsOnLand(ptX, ptY, ptZ)
    if not ground_OK then
        return false
    end

    local ents = TheSim:FindEntities(ptX, ptY, ptZ, 4, nil, notags) -- or we could include a flag to the search?
    local min_spacing = inst.components.deployable.min_spacing or 2

    for k, v in pairs(ents) do
        if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
            if distsq(Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing * min_spacing then
                return false
            end
        end
    end
    return true
end

local function StartUp(inst)
    inst.AnimState:PlayAnimation("drill_pre")
    inst:ListenForEvent("animover", DoDrilling)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/drill_pre") -- 声音模块之后再看

    inst.startup_task = nil
end

local function OnSave(inst, data)
    data.deploy_item = inst.deploy_item_save_record
end

local function OnLoadPostPass(inst, newents, data)
    if data ~= nil then
        inst.deploy_item_save_record = data.deploy_item
    end

    if inst.components.timer:TimerExists("drilling") then
        if inst.startup_task ~= nil then
            inst.startup_task:Cancel()
            inst.startup_task = nil
        end
        DoDrilling(inst)
    end
end

local function main_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 0.5) -- 设置物理属性，范围0.5
    MakeSnowCovered(inst, .01) -- 添加落雪效果，雪厚度0.01

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")

    inst:AddTag("scarytoprey")

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("timer")

    MakeMediumBurnable(inst, nil, nil, false) -- 完全烧毁
    MakeLargePropagator(inst)
    inst:ListenForEvent("burntup", function(var)
        -- 被完全烧毁时，去掉timer
        if var.components.timer:TimerExists("drilling") then
            var.components.timer:StopTimer("drilling")
        end
    end)

    inst.deploy_item_save_record = nil

    inst.startup_task = inst:DoTaskInTime(0, StartUp)

    inst:ListenForEvent("timerdone", timerdone) -- timer计时器完毕事件

    inst.OnSave = OnSave
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:PlayAnimation("idle_packed")

    inst:AddTag("usedeploystring")
    inst:AddTag("tile_deploy")

    MakeInventoryFloatable(inst, "idle_packed", "idle_packed") --添加漂浮 注意，单机的漂浮和联机不同

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem") -- 可放入背包
    -- 纹理图集
    inst.components.inventoryitem.atlasname = "images/inventoryimages/inventoryimages1.xml"
    -- 表示使用图集中的哪个图片
    inst.components.inventoryitem.imagename = "farm_plow_item"

    inst:AddComponent("deployable") -- 可部署or放置组件
    inst.components.deployable.ondeploy = item_ondeploy -- 放置后执行函数
    inst.components.deployable.test = test_ground -- 查看是否可以放置
    inst.components.deployable.min_spacing = 2 -- 放置间隔0
    inst.components.deployable.placer = "farm_plow_item_placer"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove) -- 用完时移除
    inst.components.finiteuses:SetMaxUses(4) -- 最大使用次数
    inst.components.finiteuses:SetUses(4) -- 当前使用次数

    MakeSmallBurnable(inst) -- 可点燃
    MakeSmallPropagator(inst) -- 可烧毁

    return inst
end

local function place_fn(data)

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank(data.bank or "farm_plow")
    inst.AnimState:SetBuild(data.build or "farm_plow")
    inst.AnimState:PlayAnimation(data.anim or "idle_place", true)
    inst.AnimState:SetLightOverride(1)

    if data.facing == "two" then
        inst.Transform:SetTwoFaced()
    elseif data.facing == "four" then
        inst.Transform:SetFourFaced()
    elseif data.facing == "six" then
        inst.Transform:SetSixFaced()
    elseif data.facing == "eight" then
        inst.Transform:SetEightFaced()
    end

    inst:AddTag("placer")

    inst:AddComponent("placer")
    inst.persists = false
    inst.components.placer.snap_to_tile = data.snap_to_tile or true
    inst.components.placer.snaptogrid = data.snap
    inst.components.placer.snap_to_meters = data.metersnap
    inst.components.placer.snap_to_flood = data.snap_to_flood
    inst.components.placer.fixedcameraoffset = data.fixedcameraoffset
    inst.components.placer.hide_on_invalid = data.hide_on_invalid
    inst.components.placer.hide_on_ground = data.hide_on_ground

    if data.modifyfn then
        inst.components.placer:SetModifyFn(data.modifyfn)
    end

    if data.placeTestFn then
        inst.components.placer.placeTestFn = data.placeTestFn
    end

    local _scale = data.scale or 1
    inst.Transform:SetScale(_scale, _scale, _scale)

    if data.onground then
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    end

    inst.animdata = {}
    inst.animdata.build = data.build
    inst.animdata.anim = data.anim
    inst.animdata.bank = data.bank

    inst:ListenForEvent("onremove", function()
        if inst.markers then
            for i, marker in ipairs(inst.markers) do
                marker:Remove()
            end
        end
    end)

    if data.preSetPrefabfn then
        data.preSetPrefabfn(inst)
    end

    return inst
end

return Prefab("farm_plow", main_fn, assets, prefabs),
Prefab("farm_plow_item", item_fn, assets_item, prefabs_item),
Prefab("farm_plow_item_placer", place_fn)

