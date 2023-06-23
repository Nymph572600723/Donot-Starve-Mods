--require "prefabutil"
--
--local assets = {
--    Asset("ANIM", "anim/dock_damage.zip"),
--}
--
--local function fn(Sim)
--    local inst = CreateEntity() -- 创建实体
--    inst.entity:AddTransform() -- 添加xyz形变对象
--    inst.entity:AddAnimState() -- 添加动画状态
--    inst.entity:AddSoundEmitter()
--
--    inst.AnimState:SetBank("dock_damage")
--    inst.AnimState:SetBuild("dock_damage")
--    inst.AnimState:PlayAnimation("idle1")
--    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
--    inst.AnimState:SetLayer(LAYER_BACKGROUND)
--    inst.AnimState:SetSortOrder(3)
--    inst.AnimState:SetRayTestOnBB(true)
--
--    inst.entity:SetPristine()
--
--    return inst
--end
--
--return Prefab("dock_damage", fn, assets)