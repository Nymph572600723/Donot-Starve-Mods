-- env设置
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

PrefabFiles = {
    -- 载入预制体与placer建筑放置辅助工具
    "slotmachineplacer",
    "cranny"
}

Assets = {
    Asset("ATLAS", "images/inventoryimages/slotmachine.xml"), -- 导入资源
}

local slotmachine = Recipe("slotmachine", -- 预制体
        {
            Ingredient("cranny", 1),
            Ingredient("transistor", 2),
            Ingredient("nightmarefuel", 4),
            Ingredient("bamboo", 4),
        },
        RECIPETABS.MAGIC, -- 魔法栏
        TECH.MAGIC_THREE, -- 科技魔法2本
        RECIPE_GAME_TYPE.SHIPWRECKED, -- 游戏类型，表明这个配方属于哪个DLC的，可以为nil
        "slotmachine_placer" -- placer
)
slotmachine.atlas = "images/inventoryimages/slotmachine.xml" -- atlas资源必须与预制体一致

local function onhammered(inst, worker)
    -- 释放掉落物
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit") -- 播放受损动画
        inst.AnimState:PushAnimation("idle", true) -- 播放完毕后重新播放idle动画
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/ice_box")
end

-- 为抽奖机的宝藏添加自定义宝藏
local loot_defs = require("prefabs/slotmachine_loot_defs")
local actions = loot_defs.ACTIONS
actions.slot_custom = { treasure = "slot_custom", }

-- 添加全局宝藏
AddTreasureLoot("slot_custom",
        {
            loot = {
                cranny = 1,
            },
        }
)

local odds = GetModConfigData("ODDS", 0.01)
local odds_test = GetModConfigData("ODDS_TEST", false)

--- 检测游戏是否安装此DLC
--local rog = IsDLCInstalled(REIGN_OF_GIANTS) -- 巨人国
--local sw = IsDLCInstalled(CAPY_DLC) -- 海难
--local hmlet = IsDLCInstalled(PORKLAND_DLC) -- 哈姆雷特

--- 检测存档是否兼容此DLC
--local rog2 = IsDLCEnabled(REIGN_OF_GIANTS) -- 巨人国
--local sw2 = IsDLCEnabled(CAPY_DLC) -- 海难
local hmlet2 = IsDLCEnabled(PORKLAND_DLC) -- 哈姆雷特




-- 添加随机抽取核心的方法
local function NewPickPrize(inst)
    local func = inst.components.payable.onaccept
    if func then
        -- debug 替换 PickPrize 执行逻辑
        local i = 0
        local _value
        local _name = ''

        if func then
            while _name ~= 'PickPrize' do
                -- while循环找一下bar()函数的位置
                i = i + 1
                _name, _value = debug.getupvalue(func, i)
            end
        end

        --if hmlet2 then
        local fn = function(var1)
            _value(var1)
            if odds_test or math.random() <= odds then
                var1.prizevalue = "good"
                var1.prize = "slot_custom"
            end
        end

        -- 需要兼容哈姆雷特
        if hmlet2 then
            fn = function(var1, var2)
                _value(var1, var2)

                if odds_test or math.random() <= odds then
                    if not var2.prefab ~= "dubloon" then
                        var1.prizevalue = "good"
                        var1.prize = "slot_custom"
                    end
                end
            end
        end
        debug.setupvalue(func, i, fn)
    end

end

AddPrefabPostInit('slotmachine', function(inst)

    MakeSnowCovered(inst, .01) -- 添加落雪效果，雪厚度0.01

    inst:AddComponent("workable") -- 添加工作组件
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- 锤击操作
    inst.components.workable:SetWorkLeft(7) -- 锤7下摧毁
    inst.components.workable:SetOnFinishCallback(onhammered) -- 锤完毕回调
    inst.components.workable:SetOnWorkCallback(onhit) -- 锤过程中调用
    --主动设置掉落表
    --if inst.components.lootdropper then
    --    inst.components.lootdropper:SetChanceLootTable("slotmachine_budle")
    --end
    inst:ListenForEvent("onbuilt", onbuilt) -- 监听建筑完成时

    NewPickPrize(inst)
end)



