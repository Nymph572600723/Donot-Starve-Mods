-- 我瞎几把写，你瞎几把看

local assets = {
    Asset("ANIM", "anim/dreadsword.zip"),
    Asset("ANIM", "anim/swap_dreadsword.zip")
}

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_dreadstone")
end

local function OnFinished(inst)
    inst:Remove()
end

local function DoRegen(inst, owner)
    if owner.components.sanity ~= nil and owner.components.sanity:IsInsanityMode() and not (inst.components.finiteuses:GetPercent() == 1)  then
        local setbonus = inst.components.setbonus ~= nil and inst.components.setbonus:IsEnabled(EQUIPMENTSETNAMES.DREADSTONE) and TUNING.DREADSWORD.REGEN_SETBONUS or 1
        local rate = 1 / Lerp(1 / TUNING.DREADSWORD.REGEN_MAXRATE, 1 / TUNING.DREADSWORD.REGEN_MINRATE, owner.components.sanity:GetPercent())
        if inst.isonattack then
            rate = rate * 2.5
        end
        inst.components.finiteuses:Repair(inst.components.finiteuses.total * rate * setbonus)

        if inst.isonattack then
            inst.task = inst:DoPeriodicTask(2, function()
                inst.isonattack = false
                if inst.task then
                    inst.task :Cancel()
                    inst.task = nil
                end
            end)
        end
    end
end

local function StartRegen(inst, owner)
    if inst.regentask == nil then
        inst.regentask = inst:DoPeriodicTask(TUNING.DREADSWORD.REGEN_PERIOD, DoRegen, nil, owner)
    end
end

local function StopRegen(inst)
    if inst.regentask ~= nil then
        inst.regentask:Cancel()
        inst.regentask = nil
    end
end

local function GetSetBonusEquip(inst, owner, isbonus)
    local inventory = owner.components.inventory
    local hat = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
    local armor = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil
    if isbonus then
        return hat ~= nil and hat.prefab == "dreadstonehat" and hat and armor ~= nil and armor.prefab == "armordreadstone" and armor or nil
    end
    return hat ~= nil and hat.prefab == "dreadstonehat" and hat or armor ~= nil and armor.prefab == "armordreadstone" and armor or nil
end 

local function CalcDapperness(inst, owner)
    local insanity = owner.components.sanity ~= nil and owner.components.sanity:IsInsanityMode()
    local other = GetSetBonusEquip(inst, owner)
    if other ~= nil then
        return (insanity and (inst.regentask ~= nil or other.regentask ~= nil)) and 0
    end
    return insanity and inst.regentask ~= nil and TUNING.CRAZINESS_SMALL or 0
end

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_dreadsword", inst.GUID, "swap_dreadsword")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_dreadsword", "swap_dreadsword")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst:ListenForEvent("blocked", OnBlocked, owner)

    if owner.components.sanity ~= nil then
        StartRegen(inst, owner)
    else
        StopRegen(inst)
    end
end

local function OnUnEquip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    StopRegen(inst)
end

local function OnAttack(inst, attacker, target)
    if attacker.components.sanity ~= nil and GetSetBonusEquip(inst, attacker, true) then
        local inventory = attacker.components.inventory
        local hat = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        local armor = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil

        if hat ~= nil then
            hat.isonattack = true
        end

        if armor ~= nil then
            armor.isonattack = true
        end

        inst.isonattack = true
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dreadsword")
    inst.AnimState:SetBuild("dreadsword")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetSymbolLightOverride("dreadsword", .6)
    inst.AnimState:SetSymbolLightOverride("swap_dreadsword", .6)
    inst.AnimState:SetLightOverride(.6)

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("shadowlevel")
    inst:AddTag("shadow_item")

    local swap_data = {sym_build = "swap_dreadsword", bank = "dreadsword"}
    MakeInventoryFloatable(inst, "med", 0.05, {1.0, 0.4, 1.0}, true, -17.5, swap_data)  -- 漂浮需要修改

    -- inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.DREADSWORD.DAMAGE)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("shadowlevel")
    inst.components.shadowlevel:SetDefaultLevel(TUNING.DREADSWORD.SHADOW_LEVEL)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.DREADSWORD.PLANAR_DAMAGE)

    inst:AddComponent("setbonus")
    inst.components.setbonus:SetSetName(EQUIPMENTSETNAMES.DREADSTONE)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.DREADSWORD.USES)
    inst.components.finiteuses:SetUses(TUNING.DREADSWORD.USES)
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("equippable")
    inst.components.equippable.is_magic_dapperness = true
    inst.components.equippable.dapperfn = CalcDapperness
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnEquip)

    inst.isonattack = false

	-- MakeHauntableLaunch(inst) 作祟

    return inst
end

return Prefab("dreadsword", fn, assets, prefabs)
