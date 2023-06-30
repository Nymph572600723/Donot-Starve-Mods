-- 注册预制体
PrefabFiles = {
	"dreadsword"
}

Assets = {
    -- inventoryimages
    Asset("IMAGE", "images/dreadsword.tex"),
    Asset("ATLAS", "images/dreadsword.xml"),
    Asset("ATLAS_BUILD", "images/dreadsword.xml", 256),  -- for minisign
}

Util.RegisterInventoryItemAtlas("images/dreadsword.xml")
