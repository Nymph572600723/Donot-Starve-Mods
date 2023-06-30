-- env设置
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
--[[
绝望石剑
-- sword_dreadstone
“为你的敌人带去最深沉的绝望”
制作材料:绝望石*4 纯粹恐惧*4
理智:-10/min
伤害:51基础伤害+17位面伤害
使用次数:150
在被具有理智值的实体装备，且不处于启蒙
值区域时，缓慢恢复耐久。
攻击敌人时 若身上装备了绝望石头盔/绝望
石盔甲 连续攻击时获得2.5倍速度恢复它们
耐久的效果，受到伤害不中断，但停止攻击
超过1秒中断
穿戴任意一件绝望石装备后 绝望石剑的理智
降低效果取消
]]
do
    local loc = require "languages/loc"
    local lan = loc and loc.GetLanguage and loc.GetLanguage()
    L = lan ~= LANGUAGE.CHINESE_S and lan ~= LANGUAGE.CHINESE_S_RAIL
end

local file = {
    "util",
    "postinit",
    "assets",
    "tuning",
    "recipes",
    "strings",
}

for i = 1, #file do
    modimport("main/" .. file[i])
end
