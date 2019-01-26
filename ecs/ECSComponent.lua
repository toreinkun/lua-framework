-- ecs组件
local M = class("ECSComponent")

-- @field #string _name 组件在当前实体的别名
M._name = nil
-- @field #ECSEntity _entity 组件所在的实体
M._entity = nil

-- 设置组件名字
-- @param self
-- @param #string name 组件名
function M:setName(name)
	self._name = name
end

-- 获取组件名字
-- @param self
-- @return #string
function M:getName()
	return self._name
end

-- 设置组件所在的实体
-- @param self
-- @param #ECSEntity entity 
function M:setEntity(entity)
	self._entity = entity
end

-- 获取组件所在的实体
-- @param self
-- @return #ECSEntity
function M:getEntity()
	return self._entity
end

-- 获取组件所在的引擎
-- @param self
-- @return #ECSEngine
function M:getEngine()
	return self._entity:getEngine()
end

-- 组件启动
-- @param self
function M:start() end

-- 组件停止
-- @param self
function M:stop() end

return M 