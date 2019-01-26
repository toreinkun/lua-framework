local M = class("BehaviourTrigger", import(".BehaviourBase", ...))

-- 触发行为，一般是在接收分发事件的行为下，触发子行为的操作
-- @parma self
-- @param #table argument 行为变量
-- @param #object event 事件变量
function M:trigger(argument, event)
	return true
end

return M 