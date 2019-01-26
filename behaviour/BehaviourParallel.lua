local M = class("BehaviourParallel", import(".BehaviourMulti", ...))

local BehaviourObject = class("BehaviourObject")
BehaviourObject._behaviour = nil
BehaviourObject._argument = nil

function BehaviourObject:reuse(behaviour, argument)
	self._behaviour = behaviour
	self._argument = argument
end

function BehaviourObject:recycle()
	self._behaviour = nil
	self._argument = nil
end

local function _stopBehaviour(self, object)
	object._behaviour:stop(object._argument)
	return self._poolMgr:returnObject(object)
end

function M:ctor(...)
	self._stopAllHandler = handler(self, _stopBehaviour)
	return M.super.ctor(...)
end

function M:start(variable)
	local argument = self._poolMgr:getObject(Array)
	for _, behaviour in self._children:iterator() do
		result, child = behaviour:start(variable)
		if result and child then
			local object = self._poolMgr:getObject(BehaviourObject, behaviour, child)
			arugment:add(object)
			child._parent = argument
		end
	end
	if argument:count() > 0 then
		return true, argument
	else
		self._poolMgr:returnObject(argument)
		return true
	end
end

function M:stop(argument)
	arugment:clearByFunc(self._stopAllHandler)
	return self._poolMgr:returnObject(argument)
end

function M:done(child)
	local argument = child._parent
	assert(argument ~= nil, "the variable of argument can't be nil")
	
	for i, object in argument:iterator() do
		if child == object._argument then
			argument:removeAt(i)
			object._behaviour:stop(child)
			self._poolMgr:returnObject(object)
		end
	end

	if argument:count() == 0 then
		self._parent:done(argument)
	end
end

M.BehaviourObject = BehaviourObject

return M 