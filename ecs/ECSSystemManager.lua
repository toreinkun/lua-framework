-- 系统加载器接口，实现该接口的加载系统方法。
local M = class("ECSSystemManager")

-- 创建ecs系统列表
-- @param self
-- @return array_table#ECSSystem
function M:createSystems() end

return M 