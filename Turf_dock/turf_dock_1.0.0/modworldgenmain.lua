-- env设置
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

require("map/terrain")
require("map/tasks")
require("constants")
require("map/lockandkey")
require("map/layouts")
require("map/static_layout")
modimport 'scripts/tile_utils.lua'

local number = GetModConfigData("NUMBER", 118)

AddTile(
        "MONKEY_DOCK",
        number,
        "map", -- 加载瓦片地图的边界规则
        {
            noise_texture = "levels/textures/ground_noise_dock.tex", -- 瓦片地图的地图渲染图片
            runsound = "monkeyisland/dock/run_dock",
            walksound = "monkeyisland/dock/walk_dock",
            snowsound = "monkeyisland/dock/walk_dock",
            mudsound = "monkeyisland/dock/walk_dock",
            --cannotbedug = true,
            --flooring = true,
            --hard = true,
        },
        {
            -- name = "map_edge", -- tile文件夹中瓦片地图的地图规则（覆盖和地图拼合等）
            noise_texture = "levels/textures/mini_ground_noise_dock.tex" --mini地图图片
        }
)



