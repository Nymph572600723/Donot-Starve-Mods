GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
-- 地图工具
require 'util'
require 'map/terrain'
local tiledefs = require("worldtiledefs") -- 世界瓦片表

Assets = {
    Asset("SOUNDPACKAGE", "sound/monkeyisland.fev"),
    Asset("FILE", "sound/monkeyisland.fsb"),
    Asset("FILE", "sound/monkeyisland_music.fsb"),
    Asset("FILE", "sound/monkeyisland_amb.fsb"),
}

-- 添加地皮时候的默认参数，也是一个参数示例，为AddTile方法的specs参数结构
local tile_spec_defaults = {
    noise_texture = "images/square.tex", -- 地皮图案
    runsound = "dontstarve/movement/run_dirt", -- 跑步时声音
    walksound = "dontstarve/movement/walk_dirt", -- 走路时声音
    snowsound = "dontstarve/movement/run_ice", -- 雪地声音
    mudsound = "dontstarve/movement/run_mud", -- 淤泥(蛛网减速)地上声音
}
-- 小地图资源格式
local mini_tile_spec_defaults = {
    name = "map_edge",
    noise_texture = "levels/textures/mini_dirt_noise.tex",
}

-- 资源格式
local noise_locations = {
    "%s.tex",
    "levels/textures/%s.tex",
}
-- 验证地图编号 不能大于GROUND.UNDERGROUND，大于的是墙的编号；同时也不能是已存在的；
local function validate_ground_numerical_id(numerical_id)
    if numerical_id >= GROUND.UNDERGROUND then
        return error(("Invalid numerical id %d: values greater than or equal to %d are assumed to represent walls."):format(numerical_id, GROUND.UNDERGROUND), 3)
    end
    for k, v in pairs(GROUND) do
        if v == numerical_id then
            return error(("The numerical id %d is already used by GROUND.%s!"):format(v, tostring(k)), 3)
        end
    end
end
-- 获取瓦片图片资源名称
local function GroundNoise(name)
    local trimmed_name = name:gsub("%.tex$", "") -- 将.tex文件名的“.tex”后缀替换为“”，获取到文件名字
    for _, pattern in ipairs(noise_locations) do
        local tentative = pattern:format(trimmed_name)
        if softresolvefilepath(tentative) then
            -- softresolvefilepath检测路径是否符合规范，纯抄的，不知道API具体用途
            return tentative
        end
    end

    -- This is meant to trigger an error.
    local status, err = pcall(resolvefilepath, name)
    return error(err or "This shouldn't be thrown. But your texture path is invalid, btw.", 3)
end
-- Atlas资源
local GroundAtlas = GroundAtlas or function(name)
    return ("levels/tiles/%s.xml"):format(name)
end
-- Image资源
local GroundImage = GroundImage or function(name)
    return ("levels/tiles/%s.tex"):format(name)
end

local function AddAssetsTo(assets_table, specs)
    table.insert(assets_table, Asset("IMAGE", GroundNoise(specs.noise_texture)))
    table.insert(assets_table, Asset("IMAGE", GroundImage(specs.name)))
    table.insert(assets_table, Asset("FILE", GroundAtlas(specs.name)))
end
-- 添加地图瓦片资源到assets资源中
local function AddAssets(specs)
    AddAssetsTo(tiledefs.assets, specs)
end

--- id 地图ID，String
--- numerical_id 地图编号，注意不要重复
--- name 地图名称
--- specs 地图休息
--- minispecs 小地图信息
function AddTile(id, numerical_id, name, specs, minispecs)
    -- 断言判断入参是否符合规范
    assert(type(id) == "string") -- id为String类型
    assert(type(numerical_id) == "number") -- numerical_id为数字类型
    assert(type(name) == "string") -- name是数字类型
    assert(GROUND[id] == nil, ("GROUND.%s already exists!"):format(id)) -- 地皮编号不能已存在

    specs = specs or {}
    minispecs = minispecs or {}

    assert(type(specs) == "table") -- specs表
    assert(type(minispecs) == "table") -- minispecs表

    validate_ground_numerical_id(numerical_id)

    GROUND[id] = numerical_id -- 添加constant
    GROUND_NAMES[numerical_id] = name -- 添加地图Map的值

    -- 创建瓦片地图用的最终参数对象
    local real_specs = { name = name }
    -- 从specs中获取指定参数数据，若没有则从默认参数集中获取
    for k, default in pairs(tile_spec_defaults) do
        if specs[k] == nil then
            real_specs[k] = default
        else
            -- resolvefilepath() gets called by the world entity.
            real_specs[k] = specs[k]
        end
    end

    -- noise_texture参数
    real_specs.noise_texture = GroundNoise(real_specs.noise_texture)

    table.insert(tiledefs.ground, {
        GROUND[id], real_specs
    })

    AddAssets(real_specs)

    local real_minispecs = {}
    for k, default in pairs(mini_tile_spec_defaults) do
        if minispecs[k] == nil then
            real_minispecs[k] = default
        else
            real_minispecs[k] = minispecs[k]
        end
    end

    AddPrefabPostInit("minimap", function(inst)
        local handle = MapLayerManager:CreateRenderLayer(
                GROUND[id],
                resolvefilepath(GroundAtlas(real_minispecs.name)),
                resolvefilepath(GroundImage(real_minispecs.name)),
                resolvefilepath(GroundNoise(real_minispecs.noise_texture))
        )
        inst.MiniMap:AddRenderLayer(handle)
    end)

    AddAssets(real_minispecs)

    return real_specs, real_minispecs
end
