name = "建筑几何学"
description = "在放置对象时将对象固定到网格上，并在其周围显示构建网格(按住ctrl时可取消网格吸附)."
author = "rezecib"
version = "3.1.1"

forumthread = "/files/file/1108-geometric-placement/"

api_version = 6
api_version_dst = 10

priority = -10

-- Compatible with the base game, RoG, SW, and DST
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
dst_compatible = true

icon_atlas = "geometricplacement.xml"
icon = "geometricplacement.tex"

--These let clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = false

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = true

--This lets people search for servers with this mod by these tags
server_filter_tags = {}

-- 小网格尺寸
local smallgridsizeoptions = {}
for i = 0, 10 do
    smallgridsizeoptions[i + 1] = { description = "" .. (i * 2) .. "", data = i * 2 }
end
-- 中网格尺寸
local medgridsizeoptions = {}
for i = 0, 10 do
    medgridsizeoptions[i + 1] = { description = "" .. (i) .. "", data = i }
end
-- 大网格尺寸
local biggridsizeoptions = {}
for i = 0, 5 do
    biggridsizeoptions[i + 1] = { description = "" .. (i) .. "", data = i }
end

-- 按键A-Z
local KEY_A = 65
local keyslist = {}
local string = "" -- can't believe I have to do this... -____-  哈哈哈，数字转字母的传统方法
for i = 1, 26 do
    local ch = string.char(KEY_A + i - 1)
    keyslist[i] = { description = ch, data = ch }
end
keyslist[27] = { description = "None", data = "" }

-- 百分比
local percent_options = {}
for i = 1, 10 do
    percent_options[i] = { description = i .. "0%", data = i / 10 }
end
percent_options[11] = { description = "Unlimited", data = false }

-- placer辅助网格颜色选项
local placer_color_options = {
    { description = "Green", data = "green", hover = "The normal green  the game uses." }, -- 普通绿
    { description = "Blue", data = "blue", hover = "Blue, helpful if you're red/green colorblind." }, -- 为红绿色盲准备的蓝色
    { description = "Red", data = "red", hover = "The normal red the game uses." }, -- 普通红
    { description = "White", data = "white", hover = "A bright white, for better visibility." }, -- 明亮白色
    { description = "Black", data = "black", hover = "Black, to contrast with the brighter colors." }, -- 鲜艳黑色，更好的与白色对比
}

-- 颜色选项
local color_options = {}
for i = 1, #placer_color_options do
    color_options[i] = placer_color_options[i]
end
-- 白色带黑色轮廓
color_options[#color_options + 1] = { description = "Outlined White", data = "whiteoutline", hover = "White with a black outline, for the best visibility." }
-- 黑色带白色轮廓
color_options[#color_options + 1] = { description = "Outlined Black", data = "blackoutline", hover = "Black with a white outline, for the best visibility." }
-- 完全隐藏轮廓
local hidden_option = { description = "Hidden", data = "hidden", hover = "Hide it entirely, because you didn't need to see it anyway, right?" }
placer_color_options[#placer_color_options + 1] = hidden_option
color_options[#color_options + 1] = hidden_option

configuration_options = {
    {
        name = "CTRL",
        label = "CTRL Turns Mod",
        options = {
            { description = "On", data = true },
            { description = "Off", data = false },
        },
        default = false,
        -- 通过CTRL按键来确定是否启用or禁用该mod，按住禁用
        hover = "Whether holding CTRL enables or disables the mod.",
    },
    {
        name = "KEYBOARDTOGGLEKEY",
        label = "Options Button",
        options = keyslist,
        default = "B",
        -- 游戏中打开mod配置菜单的按键，默认为B
        -- hover = "A key to open the mod's options. On controllers, open\nthe scoreboard and then use Menu Misc 3 (left stick click).\nI recommend setting this with the Settings menu in DST.",
        hover = "A key to open the mod's options. On controllers, open\nthe scoreboard and then use Menu Misc 3 (left stick click). When set to None, controller is also unbound.",
    },
    {
        name = "GEOMETRYTOGGLEKEY",
        label = "Toggle Button",
        options = keyslist,
        default = "V",
        -- 将网格形状正方形与正六边形之间切换的按钮，默认为V
        -- hover = "A key to toggle to the most recently used geometry\n(for example, switching between Square and X-Hexagon). No controller binding.\nI recommend setting this with the Settings menu in DST.",
        hover = "A key to toggle to the most recently used geometry\n(for example, switching between Square and X-Hexagon). No controller binding.",
    },
    {
        name = "SNAPGRIDKEY",
        label = "Snap Grid Button",
        options = keyslist,
        default = "",
        -- 使网格锁定在一个物体或者一块地皮点的中心，默认未绑定
        -- hover = "A key to snap the grid to have a point centered on the hovered object or point. No controller binding.\nI recommend setting this with the Settings menu in DST.",
        hover = "A key to snap the grid to have a point centered on the hovered object or point. No controller binding.",
    },
    {
        name = "SHOWMENU",
        label = "In-Game Menu",
        options = {
            { description = "On", data = true },
            { description = "Off", data = false },
        },
        default = true,
        -- 游戏内的菜单UI是否能打开的配置
        hover = "If on, the button opens the menu.\nIf off, it just toggles the mod on and off.",
    },
    {
        name = "BUILDGRID",
        label = "Show Build Grid",
        options = {
            { description = "On", data = true },
            { description = "Off", data = false },
        },
        default = true,
        -- 选择是否展示构建网格
        hover = "Whether to show the build grid.",
    },
    {
        name = "GEOMETRY",
        label = "Grid Geometry",
        options = {
            { description = "Square", data = "SQUARE" },
            { description = "Diamond", data = "DIAMOND" },
            { description = "X Hexagon", data = "X_HEXAGON" },
            { description = "Z Hexagon", data = "Z_HEXAGON" },
            { description = "Flat Hexagon", data = "FLAT_HEXAGON" },
            { description = "Pointy Hexagon", data = "POINTY_HEXAGON" },
        },
        default = "SQUARE",
        -- 选择使用什么形状构建几何网格
        hover = "What build grid geometry to use.",
    },
    {
        name = "TIMEBUDGET",
        label = "Refresh Speed",
        options = percent_options,
        default = 0.1,
        -- 网格刷新速度，直接禁用或者设置过高可能导致网格显示延迟
        hover = "How much of the available time to use for refreshing the grid.\nDisabling or setting too high will likely cause lag.",
    },
    {
        name = "HIDEPLACER",
        label = "Hide Placer",
        options = {
            { description = "On", data = true },
            { description = "Off", data = false },
        },
        default = false,
        -- 选择是否隐藏placer放置器，隐藏后可更好的看到网格
        hover = "Whether to hide the placer (the ghost version of the item you're placing).\nHiding it can help you see the grid better.",
    },
    {
        name = "HIDECURSOR",
        label = "Hide Cursor Item",
        options = {
            { description = "Hide All", data = 1 },
            { description = "Show Number", data = true },
            { description = "Show All", data = false },
        },
        default = false,
        -- 选择是否隐藏光标选项
        hover = "Whether to hide the cursor item, to better see the grid.",
    },
    {
        name = "SMARTSPACING",
        label = "Smart Spacing",
        options = {
            { description = "On", data = true },
            { description = "Off", data = false },
        },
        default = false,
        -- 自动根据放置对象来调整网格的间距
        hover = "Whether to adjust the spacing of the grid based on what object is being placed.\nAllows for optimal grids, but can make it hard to put things just where you want them.",
    },
    {
        name = "ACTION_TILL",
        label = "Till Grid",
        options = {
            { description = "On", data = true },
            { description = "Off", data = false },
        },
        default = true,
        -- 是否使用网格来在种植时候挖地（DST新版种地）
        hover = "Whether to use a grid for tilling farm soil.\nAutomatically turned off when using the Snapping Tills mod.",
    },
    {
        name = "SMALLGRIDSIZE",
        label = "Fine Grid Size",
        options = smallgridsizeoptions,
        default = 10,
        -- 最小网格在一格地皮上的格子数
        hover = "How big to make the grid for things that use a fine grid (structures, plants, etc).",
    },
    {
        name = "MEDGRIDSIZE",
        label = "Medium Grid Size",
        options = medgridsizeoptions,
        default = 6,
        -- 中等网格在一格地皮上的格子数
        hover = "How big to make the grid for things that use a medium grid (such as walls, DST crops).",
    },
    {
        name = "BIGGRIDSIZE",
        label = "Large Grid Size",
        options = biggridsizeoptions,
        default = 2,
        -- 最大网格在一格地皮上的格子数
        hover = "How big to make the grid for things that use a large grid (such as turf and pitchforks).",
    },
    {
        name = "GOODCOLOR",
        label = "Unblocked Color",
        options = color_options,
        default = "whiteoutline",
        -- 可执行操作的地皮的显示颜色，例如种植的时候绿色表示可种植的点
        hover = "The color to use for unblocked points, where you can place things.",
    },
    {
        name = "BADCOLOR",
        label = "Blocked Color",
        options = color_options,
        default = "blackoutline",
        -- 不可执行操作的地皮的显示颜色，例如种植的时候红色表示该点不可种植
        hover = "The color to use for blocked points, where you cannot place things.",
    },
    {
        name = "NEARTILECOLOR",
        label = "Nearest Tile Color",
        options = color_options,
        default = "white",
        -- 当前地皮格子周围地皮轮廓的颜色
        hover = "The color to use for the nearest tile outline.",
    },
    {
        name = "GOODTILECOLOR",
        label = "Unblocked Tile Color",
        options = color_options,
        default = "whiteoutline",
        -- 可放置地皮的颜色
        hover = "The color to use for the turf tile grid, where you can place turf.",
    },
    {
        name = "BADTILECOLOR",
        label = "Blocked Tile Color",
        options = color_options,
        default = "blackoutline",
        -- 不可放置地皮的颜色
        hover = "The color to use for the turf tile grid, where you can't place turf.",
    },
    {
        name = "GOODPLACERCOLOR",
        label = "Unblocked Placer Color",
        options = placer_color_options,
        default = "white",
        -- 可执行操作时候placer放置器的颜色
        hover = "The color to use for an unblocked placer\n(the \"shadow copy\" of the thing you're placing).",
    },
    {
        name = "BADPLACERCOLOR",
        label = "Blocked Placer Color",
        options = placer_color_options,
        default = "black",
        -- 不可执行操作时候placer放置器的颜色
        hover = "The color to use for a blocked placer\n(the \"shadow copy\" of the thing you're placing).",
    },
    {
        name = "REDUCECHESTSPACING",
        label = "Tighter Chests",
        options = {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = true,
        -- 是否允许箱子可以放的更近一些（DST中可能不起作用）
        hover = "Whether to allow chests to be placed closer together than normal.\nThis may not work in DST.",
    },
    {
        name = "CONTROLLEROFFSET",
        label = "Controller Offset",
        options = {
            { description = "On", data = true },
            { description = "Off", data = false },
        },
        default = false,
        -- 控制器是否放在你的脚下还是放置在偏移位置
        hover = "With a controller, whether objects get placed\nright at your feet (\"off\") or at an offset (\"on\").",
    },
}