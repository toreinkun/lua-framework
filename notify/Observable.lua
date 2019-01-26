local ipairs = ipairs
local assert = assert
local string = string
local t_remove = table.remove

-- 被观察对象，然后给它添加观察者则可
local M = setglobal("Observable", class("Observable"))

-- 观察者
local Observer = {}
-- @field #object _obj 回调对象
Observer._obj = nil
-- @field #function _callback 回调函数
Observer._callback = nil
-- @field #int _tag 观察者标签
Observer._tag = 0
-- @field #boolean _invalid 观察者是否可用
Observer._invalid = false

-- @field #int _currentTag 当前使用到的标签值
M._currentTag = 0
-- @field array_table#Observer _observers 观察者数组
M._observers = nil
-- @field #int _observerCnt 观察者数量
M._observerCnt = 0
-- @field array_table#Observer _toAddedObservers 等待加入的观察者
M._toAddedObservers = nil
-- @field #int _toAddedCnt 等待加入的观察者数量
M._toAddedObserverCnt = 0
-- @field #boolean _existsRemove 是否在通知事件中，删除了一些观察者
M._existsRemove = false
-- @field #int _inNotifyObserver 是否正在通知事件上
M._inNotifyObserver = 0

-- @field array_table#Observer _observerPoolInstance 观察者对象池实例
M._observerPoolInstance = nil
-- @field #int _observerPoolSize 观察者对象池大小
M._observerPoolSize = 0

-- 把观察者放回对象池
-- @param self
-- @param #Observer observer 
local function _returnObserver(self, observer)
	observer._callback = nil
	observer._obj = nil
	observer._invalid = false
	self._observerPoolSize = self._observerPoolSize + 1
	self._observerPoolInstance[self._observerPoolSize] = observer
end

-- 获取一个观察者
-- @param self
-- @param #int tag 观察者标签
-- @param #function callback 回调
-- @return #Observer
local function _getObserver(self, callback, obj)
	local observer = nil
	if self._observerPoolSize == 0 then
		observer = {}
	else
		observer = self._observerPoolInstance[self._observerPoolSize]
		self._observerPoolSize = self._observerPoolSize - 1
	end
	observer._tag = self._currentTag
	observer._callback = callback
	observer._obj = obj
	return observer
end

-- 初始化观察者数组、等待加入的观察者数组、对象池
-- @param self
function M:ctor()
	self._observers = {}
	self._toAddedObservers = {}
	self._observerPoolInstance = {}
end

-- 通知观察者，尽量不要在通知的回调中再调用这个方法，免得死循环
-- @param self
-- @param #va_list ... 通知参数
function M:notifyObservers(...)
	local observers = self._observers
	self._inNotifyObserver = self._inNotifyObserver + 1
	for _, observer in ipairs(observers) do
		if not observer._invalid then
			if observer._obj then
				observer._callback(observer._obj, ...)
			else
				observer._callback(...)
			end
		end
	end
	self._inNotifyObserver = self._inNotifyObserver - 1
	if self._inNotifyObserver ~= 0 then
		return
	end
	-- 移除待删除的观察者
	if self._existsRemove then
		local observerCnt = self._observerCnt
		for i = #observers, 1, - 1 do
			if observers[i]._invalid then
				observerCnt = observerCnt - 1
				_returnObserver(self, observers[i])
				observers[i] = nil
			end
		end
		self._observerCnt = observerCnt
		self._existsRemove = false
	end
	-- 把待加入的观察者加进数组
	if self._toAddedObserverCnt > 0 then
		local observerCnt = self._observerCnt
		local toAddedObservers = self._toAddedObservers
		for i = 1, self._toAddedObserverCnt do
			observerCnt = observerCnt + 1
			observers[observerCnt] = toAddedObservers[i]
			toAddedObservers[i] = nil
		end
		self._observerCnt = observerCnt
		self._toAddedObserverCnt = 0
	end
end

-- 添加一个观察者，并返回它的标签
-- @param self
-- @param #function callback 回调函数
-- @param #object obj 回调对象
-- @return #int 
function M:addObserver(callback, obj)
	assert(type(callback) == "function", string.format("the parameter of callback:%s is not function", tostring(callback)))
	self._currentTag = self._currentTag + 1
	local observer = _getObserver(self, callback, obj)
	observer._tag = self._currentTag
	if self._inNotifyObserver > 0 then
		self._toAddedObserverCnt = self._toAddedObserverCnt + 1
		self._toAddedObservers[self._toAddedObserverCnt] = observer
	else
		self._observerCnt = self._observerCnt + 1
		self._observers[self._observerCnt] = observer
	end
	return self._currentTag
end

-- 根据一个标签移除一个观察者
-- @param self
-- @param #int tag 
function M:removeObserverByTag(tag)
	assert(type(tag) == "number", string.format("the parameter of tag:%s is not number", tostring(tag)))
	if self._inNotifyObserver > 0 then
		-- 在使用中的观察者数组寻找
		for i, observer in ipairs(self._observers) do
			if observer._tag == tag then
				observer._invalid = true
				-- 标记在通知观察者的过程中有删除观察者的操作
				self._existsRemove = true
				return
			end
		end
		-- 在待加进的数组中寻找
		for i, observer in ipairs(self._toAddedObservers) do
			if observer._tag == tag then
				t_remove(self._toAddedObservers, i)
				self._toAddedObserverCnt = self._toAddedObserverCnt - 1
				return _returnObserver(self, observer)
			end
		end
	else
		-- 不是在通知观察者的过程中，直接从使用中的数组中删除
		for i, observer in ipairs(self._observers) do
			if observer._tag == tag then
				t_remove(self._observers, i)
				self._observerCnt = self._observerCnt - 1
				return _returnObserver(self, observer)
			end
		end
	end
end

-- 移除所有的观察者
-- @param self
function M:removeAllObservers()
	if self._inNotifyObserver > 0 then
		for i, observer in ipairs(self._observers) do
			observer._invalid = false
		end
	else
		local observers = self._observers
		for i = 1, self._observerCnt do
			_returnObserver(self, observers[i])
			observers[i] = nil
		end
		self._observerCnt = 0
	end
end


-- 根据回调函数和回调对象移除观察者
-- @param self
-- @param #functioncallback 
-- @param #object obj 
-- @param #boolean removeall 是否移除所有与一个回调函数相关的观察者
function M:removeObserver(callback, obj, removeall)
	assert(type(callback) == "function", string.format("the parameter of callback:%s is not function", tostring(callback)))
	if self._inNotifyObserver > 0 then
		for i, observer in ipairs(self._observers) do
			if observer._callback == callback and observer._obj == obj then
				observer._invalid = true
				self._existsRemove = true
				if not removeall then return end
			end
		end
		local toAddedObservers = self._toAddedObservers
		for i = self._toAddedObserverCnt, 1, - 1 do
			local observer = toAddedObservers[i]
			if observer._callback == callback and observer._obj == obj then
				t_remove(toAddedObservers, i)
				self._toAddedObserverCnt = self._toAddedObserverCnt - 1
				_returnObserver(self, observer)
				if not removeall then return end
			end
		end
	else
		local observers = self._observers
		for i = self._observerCnt, 1, - 1 do
			local observer = observers[i]
			if observer._callback == callback and observer._obj == obj then
				t_remove(observers, i)
				self._observerCnt = self._observerCnt - 1
				_returnObserver(self, observer)
				if not removeall then break end
			end
		end
	end
end

return M 