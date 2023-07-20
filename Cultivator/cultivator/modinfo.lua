name = "耕地机"

description = "耕地机测试"

version = "1.0.1"

author = "Dingdang"

api_version = 6
api_version_dst = 10
priority = 0 -- 加载权重


--dst_compatible = true--是否兼容DST（联机）
--all_clients_require_mod = true -- 要求此mod所有客户端都必须加载
--client_only_mod = false --仅客户端mod

dont_starve_compatible = true -- 单机本体支持
reign_of_giants_compatible = true -- 兼容巨兽统治
shipwrecked_compatible = true -- 兼容海难
hamlet_compatible = true -- 兼容哈姆雷特

server_filter_tags = {}

icon = "farm_plow_item.tex" -- 图标
icon_atlas = "farm_plow_item.xml" -- 纹理


forumthread = ""

opts = {}
for i = 1, 52 do
    opts[i] = {
        description = "编号：" .. (66 + i),
        data = (66 + i)
    }
end

configuration_options = {
    {
        name = "FARMING_SOIL",
        label = "耕种地皮编号", -- 配置显示名称，支持中文显示
        -- hover = "on mouse hover hint", -- 鼠标悬停显示
        options = opts, -- options是属性选项
        default = 99 --default是默认值
    },
}