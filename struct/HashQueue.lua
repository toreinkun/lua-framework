-- 用hash表实现的队列
local M = class("HashQueue", import(".Queue", ...))

-- @field map<#int,#object> _queue 队列容器
M._queue = nil
-- @field #int _front 头索引
M._front = 1
-- @field #int _back 尾索引 指向最后一个数据的下一个空位置
M._back = 1

-- 初始化，可加入若干初始数据
-- @param self
-- @param va_list#object ... 
function M:ctor(...)
	self._queue = {}
	self:enqueues(...)
end

-- 把多个数据加进队列
-- @param self
-- @param va_list#object ... 
function M:enqueues(...)
	for _, value in ipairs {...} do
		self:enqueue(value)
	end
end

-- 把一个数据加进队列
-- @param self
-- @param #object value
function M:enqueue(value)
	self._queue[self._back] = value
	self._back = self._back + 1
end

-- 把一个数据从队列拿出来
-- @param self
-- @return #object
function M:dequeue()
	local value = self._queue[self._front]
	if not value then
		return
	end
	self._queue[self._front] = nil
	self._front = self._front - 1
	return value
end

-- 清空队列
-- @param self
function M:clear()
	local queue = self._queue
	for i = self._front, self._back do
		queue[i] = nil
	end
	self._back = self._front
end

-- 是否包含这个值
-- @param self
-- @return #bool
function M:contains(value)
	local queue = self._queue
	for i = self._front, self._back - 1 do
		if queue[i] == value then
			return true
		end
	end
	return false
end

-- 获取队列的长度
-- @param self
-- @return #int
function M:count()
	return self._back - self._front
end


-- 队列的迭代器
-- @return #function 迭代函数
-- @return #object
-- @return #object 
local function _iterator(self, current)
	local value = self._queue[self._front + current - 1]
	if not value then
		return nil
	else
		return current + 1, value
	end
end

-- 获取队列的迭代器，从加进队列的顺序排序
-- @param self
-- @return #function 迭代函数
-- @return #object
-- @return #object 
function M:iterator()
	return _iterator, self, 1
end

-- 队列是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self:count() == 0
end

-- 浅克隆队列
-- @param self
-- @return #LinkedQueue
function M:clone()
	local result = M.new()
	result._back = self._back - self._front + 1
	local targetQueue = result._queue
	local currentQueue = self._queue
	local currentFront = self._front
	for i = currentFront, self._back - 1 do
		targetQueue[i - currentFront + 1] = currentQueue[i]
	end
	return result
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString()
	local temp = {}
	local front = self._front
	for i = front, self._back - 1 do
		temp[i - front + 1] = tostring(v)
	end
	return string.format("%s[%s]", tostring(self), table.concat(temp, ","))
end

return M 