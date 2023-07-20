local assets = {
    Asset("ANIM", "anim/farm_soil.zip"),
}

--local function IsLowPriorityAction(act)
--    return act == nil or act.action ~= ACTIONS.PLANTSOIL
--end
--
----Runs on clients
--local function CanMouseThrough(inst)
--    if ThePlayer ~= nil and ThePlayer.components.playeractionpicker ~= nil then
--        local lmb, rmb = ThePlayer.components.playeractionpicker:DoGetMouseActions(inst:GetPosition(), inst)
--        return IsLowPriorityAction(rmb) and IsLowPriorityAction(lmb), true
--    end
--end

local function DisplayNameFn(inst)
    return TheInput:ControllerAttached() and TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_USEONSCENE) .. " " .. GetActionString(ACTIONS.PLANTSOIL.id) or ""
end

local function OnBreak(inst)
    if inst.is_plant then
        return
    end
    if inst:HasTag("soil") and not inst:HasTag("NOBLOCK") then
        inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")
        inst.AnimState:PlayAnimation("collapse")
        inst.AnimState:PushAnimation("collapse_idle", false)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(2)
    end
end

local function CancelPlowing(inst)
    if inst._plow ~= nil then
        inst:RemoveEventCallback("onremove", inst._onremoveplow, inst._plow)
        inst:RemoveEventCallback("finishplowing", inst._onfinishplowing, inst._plow)
        inst._plow = nil
        inst._onremoveplow = nil
        inst._onfinishplowing = nil
    end
end

local function OnCollapse(inst)
    if inst.is_plant then
        return
    end
    CancelPlowing(inst)
    if inst:HasTag("soil") then
        inst:RemoveTag("soil")
        inst.persists = false
        if inst:HasTag("NOBLOCK") then
            inst.AnimState:PlayAnimation("collapse_remove")
        else
            inst:AddTag("NOCLICK")
            inst:AddTag("NOBLOCK")
            inst.AnimState:PlayAnimation("till_remove")
        end
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function SetPlowing(inst, plow)
    CancelPlowing(inst)
    inst._plow = plow
    inst._onremoveplow = function()
        OnCollapse(inst)
    end
    inst._onfinishplowing = function(plow)
        CancelPlowing(inst) -- 移除结束塌陷
        if not inst:HasTag("NOBLOCK") then
            -- 确保移除NOBLOCK(无视阻挡)同时移除NOCLICK(不可点击)
            inst:RemoveTag("NOCLICK")
        end
    end
    inst:ListenForEvent("onremove", inst._onremoveplow, plow)
    inst:ListenForEvent("finishplowing", inst._onfinishplowing, plow)
    inst:AddTag("NOCLICK") -- 让耕地时候产生的耕地
end

local function OnSave(inst, data)
    data.broken = inst:HasTag("NOBLOCK")
    if inst.is_plant then
        data.is_plant = inst.is_plant
    end
    if inst._plow ~= nil then
        data.plow = inst._plow.GUID
        return { inst._plow.GUID } --refs
    end
end

local function OnLoad(inst, data)
    --, ents)
    if data.is_plant then
        inst.is_plant = data.is_plant
    end
    if data ~= nil and data.broken then
        OnBreak(inst)
        inst.AnimState:PlayAnimation("collapse_idle")
    else
        inst.AnimState:PlayAnimation("till_idle")
    end
end

local function OnLoadPostPass(inst, ents, data)
    if inst.is_plant then
        inst.AnimState:PlayAnimation("sow_idle", true)
    end
    if data ~= nil and data.plow ~= nil then
        local plow = ents[data.plow]
        if plow ~= nil then
            SetPlowing(inst, plow.entity)
        else
            OnCollapse(inst)
        end
    end
end

local rates = {
    TUNING.FARM1_GROW_BONUS,
    TUNING.FARM2_GROW_BONUS,
    TUNING.FARM3_GROW_BONUS,
}

local croppoints = {
    { Vector3(0, 0, 0) },
    { Vector3(0, 0, 0) },
    { Vector3(0, 0, 0) },
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    -- inst.entity:AddNetwork()

    inst.AnimState:SetBank("farm_soil")
    inst.AnimState:SetBuild("farm_soil")
    inst.AnimState:PlayAnimation("till_rise")

    inst:AddTag("soil")

    inst:AddComponent("grower")
    inst.components.grower.level = 3
    inst.components.grower.max_cycles_left = 1 -- 使用次数改为1，不允许加肥
    inst.components.grower.onplantfn = function(item)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")

        inst.is_plant = true
        inst.AnimState:PlayAnimation("sow")
        inst:ListenForEvent("animover", function(inst)
            inst.AnimState:PlayAnimation("sow_idle", true)
        end)
    end
    inst.components.grower.croppoints = croppoints[3]
    inst.components.grower.growrate = rates[3]

    -- inst:SetPhysicsRadiusOverride(TUNING.FARM_PLANT_PHYSICS_RADIUS) 联机的物理范围设置，需要换成单机的
    -- MakeObstaclePhysics(inst, 0.1) -- 设置物理属性，范围0.5，猪屋大概1.0的范围

    -- inst.CanMouseThrough = CanMouseThrough
    inst.displaynamefn = DisplayNameFn -- 此函数可以动态生成该对象的检查名称

    -- inst.entity:SetPristine()

    inst.AnimState:PushAnimation("till_idle", false)

    inst:ListenForEvent("breaksoil", OnBreak)
    inst:ListenForEvent("collapsesoil", OnCollapse)
    inst:DoPeriodicTask(15 * FRAMES, function(inst)
        if inst._plow then
            -- 耕地机耕地的时候不进行检测
            return
        end
        local tile_result = GROUND.FARMING_SOIL == GetMap():GetTileAtPoint(inst.Transform:GetWorldPosition())
        local _crops = inst.components.grower.crops -- 种植的物品
        if tile_result then
            if inst.is_plant then
                --种植状态
                for k, v in pairs(_crops) do
                    if k and k.prefab and v then
                        return
                    end
                end
            else
                return --没种植的情况下，不进行种植物检测
            end
        end
        -- 移除前挖掉作物
        for _k, _v in pairs(_crops) do
            if _v and _k and _k.components.crop then
                _k.components.crop:ForceHarvest()
            end
        end
        inst.is_plant = false -- 解除种植状态
        OnCollapse(inst)
    end)

    --Works with farm_plow
    inst._plow = nil
    inst.is_plant = false -- 种植状态
    inst.SetPlowing = SetPlowing

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("farm_soil", fn, assets)