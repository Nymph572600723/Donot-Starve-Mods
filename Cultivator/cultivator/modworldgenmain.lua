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

local number = GetModConfigData("FARMING_SOIL", 99)


AddTile(
        "FARMING_SOIL",
        number,
        "farmsoil", -- 加载瓦片地图的边界规则
        {
            noise_texture = "levels/textures/quagmire_soil_noise.tex", -- 瓦片地图的地图渲染图片
        },
        {
            -- name = "map_edge", -- tile文件夹中瓦片地图的地图规则（覆盖和地图拼合等）
            noise_texture = "levels/textures/quagmire_soil_mini.tex" --mini地图图片
        }
)
