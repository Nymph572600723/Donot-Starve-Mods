local assets = {
    Asset("ANIM", "anim/kafka.zip"), --载入在世界中时的动画
    Asset("IMAGE", "images/kafka.tex"), --载入物品的物品栏中贴图
    Asset("ATLAS", "images/kafka.xml")--贴图文件xml
}

function CreateKafka(config)
    local function fn()
        local inst = CreateEntity() -- 创建实体
        inst.entity:AddTransform() -- 添加xyz形变对象
        inst.entity:AddAnimState() -- 添加动画状态

        MakeInventoryPhysics(inst) -- 赋予物理性质

        inst.AnimState:SetBank(config.bank or config.name) -- 地上动画
        inst.AnimState:SetBuild(config.build or config.name) -- 材质包，就是anim里的zip包
        inst.AnimState:PlayAnimation(config.playanim or "idle") -- 默认播放哪个动画

        --将物品设置为可漂浮的，需要漂浮动画
        if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
            --TODO 暂时先不制作漂浮动画，使用默认动画
            MakeInventoryFloatable(inst, config.playanim_water or "idle_water", config.playanim or "idle")
        end

        inst:AddComponent("inspectable") -- 可检查组件
        inst:AddComponent("inventoryitem") -- 物品组件
        inst.components.inventoryitem.atlasname = "images/kafka.xml" --背包中的贴图

        --添加可食用组件
        inst:AddComponent("edible") -- 可腐烂的组件
        inst.components.edible.healthvalue = config.healthvalue or 0
        inst.components.edible.hungervalue = config.hungervalue or 0
        inst.components.edible.sanityvalue = config.sanityvalue or 0
        inst.components.edible.foodstate = config.foodstate or "PREPARED" -- 食物类型，例如普通，被烤过，生食，被煮过，被晾干，默认被烹饪
        inst.components.edible.foodtype = config.foodtype or "GENERIC" -- 食物类型，默认通用食物

        --腐烂组件
        if config.perishtime then
            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(config.perishtime) -- 腐烂时间
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food" -- 腐烂后变成腐烂食物
        end

        -- 可堆叠
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = config.stackable or TUNING.STACK_SIZE_SMALLITEM

        --燃烧组件，让食物可燃
        if config.burnable then
            MakeSmallBurnable(inst)
            MakeSmallPropagator(inst)
        end

        -- 诱饵组件
        inst:AddComponent("bait")

        -- 可交易组件
        inst:AddComponent("tradable")

        return inst
    end
    -- 创建预制体，目录common/inventory/为公共列表
    return Prefab("common/inventory/" .. config.name, fn, assets)
end

local config = {
    name = "kafka",
    healthvalue = 11,
    sanityvalue = 22,
    hungervalue = 33,
    perishtime = TUNING.PERISH_PRESERVED;
}


return CreateKafka(config)

