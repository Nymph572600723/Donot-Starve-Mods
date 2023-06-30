local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function DoRegen(inst, owner)
    if owner.components.sanity ~= nil and owner.components.sanity:IsInsanityMode() then
        local setbonus = inst.components.setbonus ~= nil and inst.components.setbonus:IsEnabled(EQUIPMENTSETNAMES.DREADSTONE) and TUNING.ARMOR_DREADSTONE_REGEN_SETBONUS or 1
        local rate = 1 / Lerp(1 / TUNING.ARMOR_DREADSTONE_REGEN_MAXRATE, 1 / TUNING.ARMOR_DREADSTONE_REGEN_MINRATE, owner.components.sanity:GetPercent())
        if inst.isonattack then
            rate = rate * 2.5
        end
        inst.components.armor:Repair(inst.components.armor.maxcondition * rate * setbonus)
    end

    if inst.isonattack then
        inst.task = inst:DoPeriodicTask(TUNING.ARMOR_DREADSTONE_REGEN_PERIOD, function()
            inst.isonattack = false
            if inst.task then
                inst.task :Cancel()
                inst.task = nil
            end
        end)
    end

    if not inst.components.armor:IsDamaged() then
        inst.regentask:Cancel()
        inst.regentask = nil
    end
end

local function StartRegen(inst, owner)
    if inst.regentask == nil then
        inst.regentask = inst:DoPeriodicTask(TUNING.ARMOR_DREADSTONE_REGEN_PERIOD, DoRegen, nil, owner)
    end
end

local function postinitfn(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst.isonattack = false

    -- Hook
    local OnEquip = inst.components.equippable.onequipfn
    local OnUnEquip = inst.components.equippable.onunequipfn
    local OnTakeDamage = inst.components.armor.ontakedamage

    function inst.components.equippable.onequipfn(inst, owner)
        if inst.components.sanity ~= nil and inst.components.armor:IsDamaged() then
            StartRegen(inst, owner)
        end
        OnEquip(inst, owner)
    end

    function inst.components.armor.ontakedamage(inst, amount)
        local owner = inst.components.inventoryitem.owner
        if inst.regentask == nil and inst.components.equippable:IsEquipped() then
            if owner ~= nil and owner.components.sanity ~= nil then
                StartRegen(inst, owner)
            end
        end
        OnTakeDamage(inst, owner)
    end

end

local t = {
    "dreadstonehat",
    "armordreadstone"
}

for _,v in pairs(t) do
    AddPrefabPostInit(v, postinitfn)
end
