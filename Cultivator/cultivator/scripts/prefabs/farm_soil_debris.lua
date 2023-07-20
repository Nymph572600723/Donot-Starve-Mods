local assets =
{
    Asset("ANIM", "anim/farm_soil_debris.zip"),
    Asset("ANIM", "anim/farm_soil.zip"),
    Asset("ANIM", "anim/smoke_puff_small.zip"),
}

local prefabs =
{
    "smoke_puff"
}

local anim_names = { "f1", "f2", "f3", "f4" }

local chance_loot =
{
	twigs = 40,
	rocks = 25,
	flint = 20,
	nitre = 10,
	goldnugget = 5,
}

for k, _ in pairs(chance_loot) do
	table.insert(prefabs, k)
end

local function onfinishcallback(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    SpawnPrefab("smoke_puff").Transform:SetPosition(x, y, z)
    inst:Remove()

    inst.components.lootdropper:DropLoot() -- 掉落物品
end

local function OnSpawnIn(inst)
	inst:Show()
    inst.AnimState:PlayAnimation(inst.animname.."_pre", false)
    inst.AnimState:PushAnimation(inst.animname, false)
end

local function onsave(inst, data)
    data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
        inst.AnimState:PlayAnimation(inst.animname)
		inst:Show()
		if inst._spawn_task ~= nil then
			inst._spawn_task:Cancel()
			inst._spawn_task = nil
		end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddNetwork()

    inst:AddTag("farm_debris")
    inst:AddTag("farm_plant_killjoy")

    inst.AnimState:SetBank("farm_soil_debris")
    inst.AnimState:SetBuild("farm_soil_debris")
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")

	inst:Hide()

    -- inst.entity:SetPristine()

    inst.animname = anim_names[math.random(#anim_names)]

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG) -- 挖掘
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.chancerandomloot = 0.25 -- 有几率掉落物品表的掉落几率
    inst.components.lootdropper.numrandomloot = 1 -- 有几率掉落物品的掉落数量
    for prefab,weight in pairs(chance_loot) do -- 循环添加，添加预制体与几率掉落权重
        inst.components.lootdropper:AddRandomLoot(prefab,weight)
    end

    -- 游戏世界生成过程中标识
	if not POPULATING then
		inst._spawn_task = inst:DoTaskInTime(0, OnSpawnIn)
	end

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("farm_soil_debris", fn, assets, prefabs)