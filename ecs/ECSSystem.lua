-- ecs系统
local M = class("ECSSystem")

-- @field #string _name 系统名
M._name = nil
-- @field #ECSEngine _engine 系统所在的引擎
M._engine = nil

-- 设置系统名字
-- @param self
-- @param #string name 系统名
function M:setName(name)
	self._name = name
end

-- 获取系统名
-- @param self
-- @return #string
function M:getName()
	return self._name
end

-- 设置系统所在的引擎
-- @param self
-- @param #ECSEngine engine ecs引擎
function M:setEngine(engine)
	self._engine = engine
end

-- 返回系统所在的引擎
-- @param self
-- @return #ECSEngine
function M:getEngine()
	return self._engine
end

-- 系统启动
-- @param self
function M:start() end

-- 系统停止
-- @param self
function M:stop() end

return M 