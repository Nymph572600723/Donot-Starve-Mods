require "prefabutil"

local assets = {
    Asset("ANIM", "anim/smoke_puff_small.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.AnimState:SetBank("small_puff")
    inst.AnimState:SetBuild("smoke_puff_small")
    inst.AnimState:PlayAnimation("puff")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("smoke_puff", fn, assets)