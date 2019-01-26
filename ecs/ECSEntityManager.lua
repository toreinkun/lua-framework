-- 实体加载器接口，实现该接口的加载实体方法
local M = class("ECSEntityManager")

-- 获取ecs实体
-- @param self
-- @param #string name 实体名
-- @return #ECSEntity
function M:getEntity(name) end

-- 归还ecs实体
-- @param self
-- @param #ECSEntity entity 要返还的实体
function M:returnEntity(entity) end

return M 