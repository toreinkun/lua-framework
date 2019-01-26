local BehaviourParallel = import(".BehaviourParallel", ...)

local M = class("BehaviourOrderSelector", BehaviourParallel)

M._count = 1

function M:ctor(behaviours, count)
	self._count = count
	return M.super.ctor(self, behaviours)
end

function M:start(variable)
	local argument = self._poolMgr:getObject(Array)
	local success = 0
	for _, behaviour in self._children:iterator() do
		result, child = behaviour:start(variable)
		if result then
			success = success + 1
			if child then
				local object = self._poolMgr:getObject(BehaviourParallel.BehaviourObject, behaviour, child)
				arugment:add(object)
				child._parent = argument
			end
			if success >= self._count then
				break
			end
		end
	end
	if count > 0 then
		return true, argument
	else
		self._poolMgr:returnObject(argument)
		return true
	end
end

return M 