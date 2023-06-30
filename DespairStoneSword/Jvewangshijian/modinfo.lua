local L = locale ~= nil and locale ~= "zh" and locale ~= "zhr" -- true 英文  false 中文

name = L and "Dread sword" or "绝望石剑"
author = "Dr_Butter, Manutsawee, 噩梦猪咪"
description = "搬运 Dingdang"

version = "1.0"
forumthread = ""
api_version = 6
api_version_dst = 10

dst_compatible = true
client_only_mod = false
all_clients_require_mod = true
priority = -1 -- 后续加载

dont_starve_compatible = true -- 单机本体支持
reign_of_giants_compatible = true -- 兼容巨兽统治
shipwrecked_compatible = true -- 兼容海难
hamlet_compatible = true -- 兼容哈姆雷特

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

server_filter_tags = { "item" }

-- local function Breaker(title_en, title_zh)  --hover does not work, as this item cannot be hovered
--     return {name = en_zh(title_en, title_zh) , options = {{description = "", data = false}}, default = false}
-- end

configuration_options = {}
