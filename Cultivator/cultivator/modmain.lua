-- env设置
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

PrefabFiles = {
    "farm_plow", -- 耕地机
    "farm_soil", -- 种植土包
    "farm_soil_debris", -- 农田杂物
    "farm_hoe", -- 锄头
    "smoke_puff", -- 灰尘特效
}

Assets = {
    Asset("IMAGE", "images/inventoryimages/ca_inventory_images.tex"),
    Asset("ATLAS", "images/inventoryimages/ca_inventory_images.xml"),
    Asset("ANIM", "anim/player_actions_till.zip"),
    Asset("SOUNDPACKAGE", "sound/farming.fev"),
    Asset("SOUND", "sound/farming.fsb")
}

modimport("scripts/constant_tuning.lua")
modimport("scripts/constant_string.lua")
modimport("scripts/recipe.lua")

local till = {
    id = "TILL",
    str = STRINGS.ACTIONS.TILL,
    fn = function(act)
        if act.pos ~= nil and act.invobject ~= nil and act.invobject.components.tillable then
            act.invobject.components.tillable:DoTill(act.doer, act.pos)
            return true
        end
    end,
    distance = 1,
    rmb = true,
    instant = false,
    priority = 10,
}
-- 添加耕地动作
AddAction(till)

local actionPreTill = State {
    name = "till_start",
    tags = { "doing", "busy" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("till_pre")
    end,

    events = {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("till")
            end
        end),
    },
}

local actionTill = State {
    name = "till",
    tags = { "doing", "busy" },

    onenter = function(inst)
        inst.AnimState:PlayAnimation("till_loop")
    end,

    timeline = {
        TimeEvent(4 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
        end),
        TimeEvent(11 * FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(12 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge")
        end),
        TimeEvent(22 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
    },

    events = {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.AnimState:PlayAnimation("till_pst")
                inst.sg:GoToState("idle", true)
            end
        end),
    },
}

AddStategraphState("wilson", actionPreTill)
AddStategraphState("wilson", actionTill)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.TILL, "till_start"))--"till_start"))
--AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CA_GROUNDPLANT, "dolongaction"))

local string_table = {
    -- 耕地机，耕地ing
    FARM_PLOW = {
        name = "耕地机",
        desc = "辛勤耕耘中...",
        recipe_desc = ""
    },
    -- 耕地机，物品
    FARM_PLOW_ITEM = {
        name = "耕地机",
        desc = "很节省体力",
        recipe_desc = "开始种地"
    },
    -- 种地土块
    FARM_SOIL = {
        name = "微型农地",
        desc = "种地咯",
        recipe_desc = ""
    },
    FARM_SOIL_DEBRIS = {
        name = "农田杂物",
        desc = "可恶的家伙...",
        recipe_desc = ""
    },
    -- 锄头
    FARM_HOE = {
        name = "锄头",
        desc = "一把锄头",
        recipe_desc = "一把锄头"
    },
    -- 金锄头
    FARM_LUX_HOE = {
        name = "金锄头",
        desc = "一把金锄头？(合金)",
        recipe_desc = "合金锄头,不是纯金的"
    }

}

for k, v in pairs(string_table) do
    STRINGS.NAMES[k] = v.name -- 物品名称
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[k] = v.desc -- 物品检查说明
    STRINGS.RECIPE_DESC[k] = v.recipe_desc --制作栏说明
end

