name = "贩售机可建造(BuildableSlotMachine)"

description = ""

version = "1.0.0"

author = "Dingdang"

api_version = 6
api_version_dst = 10
priority = 0


--dst_compatible = true--是否兼容DST（联机）
--all_clients_require_mod = true -- 要求此mod所有客户端都必须加载
--client_only_mod = false --仅客户端mod

dont_starve_compatible = true -- 单机本体支持
reign_of_giants_compatible = true -- 兼容巨兽统治
shipwrecked_compatible = true -- 兼容海难
hamlet_compatible = true -- 兼容哈姆雷特

server_filter_tags = {}

icon = "icon.tex" -- 图标
icon_atlas = "icon.xml" -- 纹理


forumthread = ""

opts = {}
for i = 1, 11 do
    opts[i] = {
        description = (0.5 + (i - 1) * .1) .. "%",
        data = 0.05 + 0.01 * (i - 1)
    }
end

configuration_options = {
    {
        name = "ODDS",
        label = "核心碎片掉落", -- 配置显示名称，支持中文显示
        -- hover = "on mouse hover hint", -- 鼠标悬停显示
        options = opts, -- options是属性选项
        default = 0.01 --default是默认值
    },

    {
        name = "ODDS_TEST",
        label = "核心必掉", -- 配置显示名称，支持中文显示
        -- hover = "on mouse hover hint", -- 鼠标悬停显示
        options = {
            {
                description = '开启',
                data = true
            }, {
                description = '关闭',
                data = false
            }
        }, -- options是属性选项
        default = false --default是默认值
    }
}