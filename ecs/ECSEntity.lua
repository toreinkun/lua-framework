-- ECS实体
local M = class("ECSEntity")

-- @field #string _name 实体名字
M._name = nil
-- @field #ECSEngine _engine 实体所在引擎
M._engine = nil

-- 实体构造
-- @param self
-- @param #string name 实体名
-- @param #ECSEngine engine 实体所在的引擎
function M:ctor(name, engine)
	self._name = name
	self._engine = engine
end

-- 返回实体的名字
-- @param self
-- @return #string
function M:getName()
	return self._name
end

-- 返回实体的所在引擎
-- @param self
-- @return #ECSEngine
function M:getEngine()
	return self._engine
end


-- 给实体添加组件，组件被添加到实体后会启动
-- @param self
-- @param #ECSComponent component 要添加的组件
function M:addComponent(component) end

-- 实体移除组件，被移除的组件会暂停
-- @param self
-- @param #string name 该组件在当前实体的别名
function M:removeComponent(name) end

-- 通过组件的别名返回组件
-- @param self
-- @param #string name 该组件在当前实体的别名
-- @return #ECSComponent
function M:getComponent(name) end

return M 