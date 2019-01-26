local M = class("BehaviourSequence", import(".BehaviourMulti", ...))

local BehaviourArgument = class("BehaviourArgument")
BehaviourArgument._index = 1
BehaviourArgument._variable = nil
BehaviourArgument._child = nil

function BehaviourArgument:reuse(index, child, variable)
	self._index = index
	self._child = child
	self._variable = variable
end

function BehaviourArgument:recycle()
	self._child = nil
	self._variable = nil
end


function M:start(variable)
	local result, child, argument
	for index, behaviour in self._children:iterator() do
		result, child = behaviour:start(variable)
		if result and child then
			argument = self._poolMgr:setObject(BehaviourArgument, index, child, variable)
			child._parent = argument
			break
		end
	end
	return result, argument
end

function M:stop(argument)
	if argument.child then
		self._children[argument._index]:stop(argument._child)
	end
	return self._poolMgr:returnObject(argument)
end

function M:done(child)
	local argument = child._parent
	assert(argument ~= nil, "the variable of argument can't be nil")
	assert(argument._child == child, "the child must be current child")
	
	child._parent = nil
	argument._child = nil
	self._children[argument._index]:stop(child)
	argument._index = argument._index + 1
	
	for index = argument._index, self._children:count() do
		result, child = self._children:get(index):start(argument._variable)
		if result and child then
			argument._index = index
			argument._child = child
			child._parent = argument
			return
		end
	end
	self._parent:done(argument)
end

return M 