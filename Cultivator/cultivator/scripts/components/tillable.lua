-- 耕地模块
local Tillable = Class(function(self, inst)
    self.inst = inst
    self.testfn = nil
    self.deployfn = nil
    self.grower = nil
end)

local FIND_SOIL_MUST_TAGS = { "soil" }
local function default_testfn(inst, doer, pos)
    local tile_type = GetMap():GetTileAtPoint(pos:Get()) -- 获取地图地皮类型
    if tile_type == nil or tile_type ~= GROUND.FARMING_SOIL then
        return false
    end

    local till_spacing = TUNING.FARM.TILL_SPACING or 1
    local x,y,z = pos:Get()
    for i, v in ipairs(TheSim:FindEntities(x,y,z, till_spacing, FIND_SOIL_MUST_TAGS)) do
        if v and v.is_plant then
            return false
        end
        -- v:PushEvent(GetDistanceSqToPoint(v, x, y, z) < till_spacing * 0.5 and "collapsesoil" or "breaksoil")
    end
    return true

end

function Tillable:CanTill(doer, pos)
    if self.testfn and type(self.testfn) == "function" then
        return self.testfn(self.inst, doer, pos)
    end
    return default_testfn(self.inst, doer, pos)
end

local function default_deployfn(inst, doer, pos)
    if inst.grower == nil then
        inst.grower = "farm_soil"
    end
    local x,y,z = pos:Get()
    if CollapseSoilAtPoint(x,y,z) then
        local fx = SpawnPrefab(inst.grower)
        fx.Transform:SetPosition(pos:Get())
    end

end

function Tillable:DoTill(doer, pos)
    if self.inst.components.finiteuses then
        self.inst.components.finiteuses:Use(TUNING.FARM.HOE.USE_CONSUME)
    end
    if self.deployfn and type(self.deployfn) == "function" then
        self.deployfn(doer, pos)
    else
        default_deployfn(self.inst, doer, pos)
    end
end

-- （收集物品行为）：这个函数用于收集与玩家的物品栏中的物品相关的行为。它会返回一个包含可执行的物品行为列表的表
function Tillable:CollectInventoryActions(doer, actions, right)

end
-- （收集装备行为）：这个函数用于收集与玩家当前装备的物品相关的行为。它会返回一个包含可执行的装备行为列表的表
function Tillable:CollectEquippedActions(doer, target, actions, right)

end
-- （收集点行为）：这个函数用于收集与指定的点（坐标）相关的行为。它会返回一个包含可执行的点行为列表的表
function Tillable:CollectPointActions(doer, pos, actions, right)
    -- 耕种，右键动作
    if right and self:CanTill(doer, pos) then
        table.insert(actions, ACTIONS.TILL)
    end
end
-- （收集使用行为）：这个函数用于收集与特定物品的使用相关的行为。它会返回一个包含可执行的使用行为列表的表
function Tillable:CollectUseActions(doer, target, actions, right)

end
--预制体使用这个方法
--function Tillable:CollectUseActions(useitem, actions, right)
--end
-- （收集场景行为）：这个函数用于收集与当前场景（例如周围环境、地面或建筑物）相关的行为。它会返回一个包含可执行的场景行为列表的表
function Tillable:CollectSceneActions(doer, actions, right)

end

return Tillable