local M = class("EventDispatcher")

local ipairs = ipairs
local t_remove = table.remove

-- 侦听器
local EventL = {}
-- 回调函数
EventL.__listener__ = nil
-- 回调对象
EventL.__listenerCaller__ = nil
-- 侦听器是否无效
EventL.__invalid__ = false
-- 标签
EventL.__tag__ = 0

-- 针对一个事件名，侦听器容器
local EventT = {}
-- 侦听器列表
EventT.__listeners__ = nil
-- 侦听器个数
EventT.__listenerCount__ = 0
-- 是否被锁住，用于防止在dispatch事件的过程中，对该事件的侦听器列表进行增减操作导致的异常
EventT.__isLocked__ = 0
-- 被锁住时存在删除事件
EventT.__existsRemove__ = false
-- 被锁住时添加事件列表
EventT.__toAddListeners__ = nil
-- 被锁住时添加事件数量
EventT.__toAddListenerCount__ = 0

M.__eventMap__ = nil
-- 当前用到的标签
M.__currentTag__ = 0
M.__eventLPoolIns__ = nil
M.__eventLPoolSize__ = 0

local function __getEventListener(self, listener, listenerCaller)
	local eventLPoolSize = self.__eventLPoolSize__
	if eventLPoolSize == 0 then
		return {
			__listener__ = listener,
			__listenerCaller__ = listenerCaller
		}
	end
	local eventL = self.__eventLPoolIns__[eventLPoolSize]
	self.__eventLPoolSize__ = eventLPoolSize - 1
	eventL.__listener__ = listener
	eventL.__listenerCaller__ = listenerCaller
	return eventL
end

local function __returnEventListener(self, eventL)
	eventL.__invalid__ = false
	eventL.__listener__ = nil
	eventL.__listenerCaller__ = nil
	self.__eventLPoolSize__ = self.__eventLPoolSize__ + 1
	self.__eventLPoolIns__[self.__eventLPoolSize__] = eventL
end

-- 构造方法
function M:ctor()
	self.__eventMap__ = {}
	self.__eventLPoolIns__ = {}
end

function M:clear()
	for name, eventT in pairs(self.__eventMap__) do
		if eventT.__isLocked__ > 0 then
			for i = 1, eventT.__toAddListenerCount__ do
				__returnEventListener(self, eventT.__toAddListeners__[i])
				eventT.__toAddListeners__[i] = nil
			end
			for _, eventL in ipairs(eventT.__listeners__) do
				eventL.__invalid__ = true
				eventT.__existsRemove__ = true
			end
		else
			for _, eventL in ipairs(eventT.__listeners__) do
				__returnEventListener(self, eventL)
			end
			self.__eventMap__[name] = nil
		end
	end
end

--[[添加事件侦听
@name			[string]事件名
@listener		[function]侦听器
@listenerCaller	[Object]侦听函数调用者
--]]
function M:addEventListener(name, listener, listenerCaller)
	assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
	assert(type(listener) == "function", "Invalid listener function!")
	
	local eventT = self.__eventMap__[name]
	if eventT == nil then
		eventT = {
			__listeners__ = {},
			__listenerCount__ = 0,
			__isLocked__ = 0,
			__existsRemove__ = false,
			__toAddListeners__ = {},
			__toAddListenerCount__ = 0
		}
		self.__eventMap__[name] = eventT
	end
	
	self.__currentTag__ = self.__currentTag__ + 1
	local eventL = __getEventListener(self, listener, listenerCaller)
	eventL.__tag__ = self.__currentTag__
	if eventT.__isLocked__ > 0 then
		eventT.__toAddListenerCount__ = eventT.__toAddListenerCount__ + 1
		eventT.__toAddListeners__[eventT.__toAddListenerCount__] = eventL
	else
		eventT.__listenerCount__ = eventT.__listenerCount__ + 1
		eventT.__listeners__[eventT.__listenerCount__] = eventL
	end
	return self.__currentTag__
end

--[[移除事件侦听
@name		[string]事件名
@listener	[function]侦听器
--]]
function M:removeEventListener(name, listener, listenerCaller, removeall)
	assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
	assert(type(listener) == "function", "Invalid listener function!")
	
	local eventT = self.__eventMap__[name]
	if eventT == nil then
		return
	end
	
	local listeners = eventT.__listeners__
	if eventT.__isLocked__ > 0 then
		for _, eventL in ipairs(listeners) do
			if eventL.__listener__ == listener and eventL.__listenerCaller__ == listenerCaller then
				eventL.__invalid__ = true
				eventT.__existsRemove__ = true
				if not removeall then return end
			end
		end
		local toAddListeners = eventT.__toAddListeners__
		for i = eventT.__toAddListenerCount__, 1, - 1 do
			local eventL = toAddListeners[i]
			if eventL.__listener__ == listener and eventL.__listenerCaller__ == listenerCaller then
				t_remove(toAddListeners, i)
				eventL.__toAddListenerCount__ = eventL.__toAddListenerCount__ - 1
				__returnEventListener(self, eventL)
				if not removeall then return end
			end
		end
	else
		for i = eventT.__listenerCount__, 1, - 1 do
			local eventL = listeners[i]
			if eventL.__listener__ == listener and eventL.__listenerCaller__ == listenerCaller then
				t_remove(listeners, i)
				eventT.__listenerCount__ = eventT.__listenerCount__ - 1
				__returnEventListener(self, eventL)
				if not removeall then return end
			end
		end
	end
end

function M:removeEventListenerByTag(name, tag)
	assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
	assert(type(tag) == "number", "Invalid tag of argument 2, need a number!")
	
	local eventT = self.__eventMap__[name]
	if eventT == nil then
		return
	end
	
	local listeners = eventT.__listeners__
	if eventT.__isLocked__ > 0 then
		for _, eventL in ipairs(listeners) do
			if eventL.__tag__ == tag then
				eventL.__invalid__ = true
				eventT.__existsRemove__ = true
				if not removeall then return end
			end
		end
		local toAddListeners = eventT.__toAddListeners__
		for i = eventT.__toAddListenerCount__, 1, - 1 do
			local eventL = toAddListeners[i]
			if eventL.__tag__ == tag then
				t_remove(toAddListeners, i)
				eventL.__toAddListenerCount__ = eventL.__toAddListenerCount__ - 1
				__returnEventListener(self, eventL)
				if not removeall then return end
			end
		end
	else
		for i = eventT.__listenerCount__, 1, - 1 do
			local eventL = listeners[i]
			if eventL.__tag__ == tag then
				t_remove(listeners, i)
				eventT.__listenerCount__ = eventT.__listenerCount__ - 1
				__returnEventListener(self, eventL)
				if not removeall then return end
			end
		end
	end
end

--[[发布事件
@name		[string]事件名
@...		其它参数
--]]
function M:dispatchEvent(name, ...)
	assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
	
	local eventT = self.__eventMap__[name]
	if eventT == nil then
		return
	end
	
	eventT.__isLocked__ = eventT.__isLocked__ + 1
	
	local listeners = eventT.__listeners__
	for _, eventL in ipairs(listeners) do
		if not eventL.__invalid__ then
			if eventL.__listenerCaller__ == nil then
				eventL.__listener__(...)
			else
				eventL.__listener__(eventL.__listenerCaller__, ...)
			end
		end
	end
	eventT.__isLocked__ = eventT.__isLocked__ - 1
	
	if eventT.__isLocked__ > 0 then
		return
	end
	
	if eventT.__existsRemove__ then
		for i = eventT.__listenerCount__, 1, - 1 do
			local eventL = listeners[i]
			if eventL.__invalid__ then
				t_remove(listeners, i)
				eventT.__listenerCount__ = eventT.__listenerCount__ - 1
				__returnEventListener(self, eventL)
			end
		end
		eventT.__existsRemove__ = false
	end
	
	if event.__toAddListenerCount__ > 0 then
		local listenerCount = eventT.__listenerCount__
		local toAddListeners = eventT.__toAddListeners__
		for i = 1, eventT.__toAddListenerCount__ do
			listenerCount = listenerCount + 1
			listeners[listenerCount] = toAddListeners[i]
			toAddListeners[i] = nil
		end
		eventT.__listenerCount__ = listenerCount
		eventT.__toAddListenerCount__ = 0
	end
end

--[[是否存在该事件侦听
@name	事件名
--]]
function M:hasEventListener(name)
	assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
	local eventT = self.__eventMap__[name]
	if not eventT then
		return false
	end
	if eventT.__isLocked__ > 0 then
		if eventT.__toAddListenerCount__ > 0 then
			return true
		end
		for _, eventL in ipairs(eventT.__listeners__) do
			if not eventL.__invalid__ then
				return true
			end
		end
		return false
	else
		return eventT.__listenerCount__ > 0
	end	
end

return M 