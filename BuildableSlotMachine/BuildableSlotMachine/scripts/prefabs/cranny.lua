local assets = {
    Asset("ANIM", "anim/cranny.zip"), --载入在世界中时的动画
    Asset("IMAGE", "images/cranny.tex"), --载入物品的物品栏中贴图
    Asset("ATLAS", "images/cranny.xml")--贴图文件xml
}

function CreateKafka(config)
    local function fn()
        local inst = CreateEntity() -- 创建实体
        inst.entity:AddTransform() -- 添加xyz形变对象
        inst.entity:AddAnimState() -- 添加动画状态

        MakeInventoryPhysics(inst) -- 赋予物理性质

        inst.AnimState:SetBank(config.bank or config.name) -- 地上动画
        inst.AnimState:SetBuild(config.build or config.name) -- 材质包，就是anim里的zip包
        inst.AnimState:PlayAnimation(config.playanim or "idle", true) -- 默认播放哪个动画

        --将物品设置为可漂浮的，需要漂浮动画
        if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
            --TODO 暂时先不制作漂浮动画，使用默认动画
            MakeInventoryFloatable(inst, config.playanim_water or "idle_water", config.playanim or "idle")
        end

        inst:AddComponent("inspectable") -- 可检查组件
        inst:AddComponent("inventoryitem") -- 物品组件
        inst.components.inventoryitem.atlasname = "images/cranny.xml" --背包中的贴图

        -- 可堆叠
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = config.stackable or TUNING.STACK_SIZE_SMALLITEM

        --燃烧组件，让食物可燃
        --if config.burnable then
        --    MakeSmallBurnable(inst)
        --    MakeSmallPropagator(inst)
        --end

        -- 诱饵组件
        inst:AddComponent("bait")

        -- 可交易组件
        inst:AddComponent("tradable")

        return inst
    end
    -- 创建预制体，目录common/inventory/为公共列表
    return Prefab("common/inventory/" .. config.name, fn, assets)
end

STRINGS.NAMES.CRANNY = "未知裂隙碎片" -- 物品名称
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CRANNY = "似乎不是遗失的..." -- 物品检查说明
-- STRINGS.RECIPE_DESC.CRANNY = "未设想的用处..." --制作栏说明

local config = {
    name = "cranny",
    --healthvalue = 11,
    --sanityvalue = 22,
    --hungervalue = 33,
    --perishtime = TUNING.PERISH_PRESERVED;
}

return CreateKafka(config)

