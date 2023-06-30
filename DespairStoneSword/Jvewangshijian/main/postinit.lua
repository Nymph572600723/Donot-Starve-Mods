local prefabs_postinit = {
    "daywalker",
    "dreadstone",
}

for _,v in pairs(prefabs_postinit) do
    modimport("postinit/prefabs/" .. v )
end
