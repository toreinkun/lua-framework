-- ECS引擎，管理系统和实体的抽象接口
local M = class("ECSEngine")

-- 启动ecs引擎
-- @param self
-- @param #ECSSystemManager systemManager 系统管理器
-- @param #ECSEntityManager entityManager 实体管理器
function M:start(systemManager, entityManager) end

-- 更新ecs引擎
-- @param self
function M:update() end

-- 停止ecs引擎
-- @param self
function M:stop() end

-- 通过名字创建实体
-- @param self
-- @return #ECSEntity
function M:createEntity(...) end

-- 删除实体
-- @param self
-- @param #ECSEntity entity 要删除的实体
function M:removeEntity(entity) end

-- 添加系统
-- @param self
-- @param #ECSSystem system 要添加的系统
function M:addSystem(system) end

-- 通过系统名从引擎移除系统
-- @param self
-- @param #string name 要删除的系统名
function M:removeSystemByName(name) end

-- 从引擎移除系统
-- @param self
-- @param #string name 要删除的系统名
function M:removeSystem(system) end

return M 