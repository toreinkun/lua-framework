-- #BehaviourBase 行为基类，行为的执行顺序是start->stop
-- 每个独立执行的行为都拥有自己的行为变量，argument，它是一个table
local M = class("BehaviourBase")

M._parent = nil
M._poolMgr = nil

function M:ctor()
	self._poolMgr = pool.manager()
end 

function M:setParent(parent)
	self._parent = parent
end

-- 启动该行为
-- @param self
-- @param #table variable 传入变量
-- @return #boolean 行为执行是否成功
-- @return #table 行为变量，持续行为才需要
function M:start(variable)
	return false
end

-- 结束该行为
-- @param self
-- @param #table argument 行为变量
function M:stop(argument) end


-- 孩子通知父行为结束
-- @param self
-- @param #table child 孩子的行为变量
function M:done(child) end

return M 