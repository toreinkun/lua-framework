local M = class("BehaviourContainer", import(".BehaviourBase", ...))

local BehaviourObject = class("BehaviourObject", pool.ObjectReusable)

BehaviourObject._tag = 0
BehaviourObject._argument = nil
BehaviourObject._behaviour = nil
BehaviourObject._callback = nil

function BehaviourObject:reuse(tag, argument, behaviour, callback)
	self._tag = tag
	self._argument = argument
	self._behaviour = behaivour
	self._callback = callback
end 

function BehaviourObject:recycle()
	self._argument = nil
	self._behaviour = nil
	self._callback = nil
end 

M._objects = nil
M._currentTag = 0
M._stopAllHandler = nil

local function _stopBehaviour(self, object)
	object._behaviour:stop(object._argument)
	return self._poolMgr:returnObject(object)
end 

function M:ctor(...)
	self._objects = Array.new()
	self._stopAllHandler = handler(self, _stopBehaviour)
	return M.super.ctor(...)
end 

function M:start()
	self._currentTag = 0
end 

function M:stop()
	self:removeAllBehaviours()
end 

-- 孩子通知父行为结束
-- @param self
-- @param #table child 孩子的行为变量
function M:done(child)
	for i, object in self._objects:iterator() do
		if child == object._argument then
			self._objects:removeAt(i)
			object._behaviour:stop(child)
			if object._callback then object._callback(true) end
			return self._poolMgr:returnObject(object)
		end
	end
end

function M:addBehaviour(behaviour, variable, callback)
	behaviour:setParent(self)
	local result, argument = behaviour:start(variable)
	if not result or not argument then
		return callback and callback(result)
	end
	
	self._currentTag = self._currentTag + 1
	local object = self._poolMgr:getObject(BehaviourObject, self._currentTag, argument, behaviour, callback)
	self._objects:add(object)
	
	return tag
end

function M:removeBehaviour(tag)
	for i, object in self._objects:iterator() do
		if tag == object.tag then
			self._objects:removeAt(i)
			object._behaviour:stop(object._argument)
			return self._poolMgr:returnObject(object)
		end
	end
end

function M:removeAllBehaviours()
	return self._objects:clearByFunc(self._stopAllHandler)
end

function M:getBehaviourCount()
	return self._objects:count()
end

return M 