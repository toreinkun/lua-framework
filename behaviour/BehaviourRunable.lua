local M = class("BehaviourRunable", import(".BehaviourBase", ...))

-- 更新该行为
-- @param self
-- @param #table argument 行为变量
-- @param #number dt 帧数差
function M:update(argument, dt) end

return M 