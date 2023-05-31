name = "KafkaCan"

description = "卡夫卡罐头"

version = "0.0.1"

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

icon_atlas = "kafka.xml"
icon = "kafka.tex"

forumthread = ""

--opts = {}
--for i = 1, 11 do
--    opts[i] = {
--        description = ((i - 1) * 10) .. "%",
--        data = 0.1 * (i - 1)
--    }
--end

configuration_options = {
    {
        name = "KAFKA_SOUND",
        label = "罐头笑声", -- 配置显示名称，支持中文显示
        -- hover = "on mouse hover hint", -- 鼠标悬停显示
        options = {
            { description = "open", data = true },
            { description = "close", data = false }
        }, -- options是属性选项
        default = ture --default是默认值
    }
}