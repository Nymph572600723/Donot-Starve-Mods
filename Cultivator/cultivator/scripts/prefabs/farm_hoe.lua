require "prefabutil"
-- 锄头
local assets = {
    Asset("ANIM", "anim/ca_lux_hoe.zip"),
    Asset("ANIM", "anim/quagmire_hoe.zip"),
    Asset("ATLAS", "images/inventoryimages/ca_inventory_images.xml"),
    Asset("IMAGE", "images/inventoryimages/ca_inventory_images.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "quagmire_hoe", "swap_quagmire_hoe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function lux_onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "ca_lux_hoe", "swap_quagmire_hoe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function lux_onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function testfn(doer, pos)
    return true
end

local function deployfn(doer, pos)

end

local function common_fn(data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        --inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation(data.anim or "idle")

        inst:AddTag("sharp")

        --inst.entity:SetPristine()

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(data.damage or 30)

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(data.lux and TUNING.FARM.HOE.LUA_MAX_USE_NUM or TUNING.FARM.HOE.MAX_USE_NUM)
        inst.components.finiteuses:SetUses(data.lux and TUNING.FARM.HOE.LUA_MAX_USE_NUM or TUNING.FARM.HOE.MAX_USE_NUM)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst.components.inventoryitem.atlasname = "images/inventoryimages/ca_inventory_images.xml"
        inst.components.inventoryitem.imagename = data.imagename

        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(data.lux and lux_onequip or onequip)
        inst.components.equippable:SetOnUnequip(data.lux and lux_onunequip or onunequip)

        inst:AddComponent("tillable")
        --inst.components.tillable.testfn = testfn
        --inst.components.tillable.deployfn = deployfn
        --MakeHauntableLaunch(inst)

        return inst
    end
    return Prefab("common/inventory/" .. data.name, fn, assets)

end
local _hoe = {
    {
        name = "farm_hoe",
        bank = "quagmire_hoe",
        build = "quagmire_hoe",
        anim = "idle",
        imagename = "farm_hoe",
    },
    {
        name = "farm_lux_hoe",
        bank = "quagmire_hoe",
        build = "ca_lux_hoe",
        anim = "idle",
        imagename = "farm_lux_hoe",
        lux = true
    }
}

local _prefabs = {}
for k, v in pairs(_hoe) do
    table.insert(_prefabs, common_fn(v))
end

return unpack(_prefabs)




