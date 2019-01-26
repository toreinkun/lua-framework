-- 用双数组实现的一个队列
local M = class("ArrayQueue", import(".Queue", ...))

-- @field array_table#object _dequeueArray 用于出队列的数据的数组
M._dequeueArray = nil
-- @field #int _dequeueCount 出队列数组长度
M._dequeueCount = 0
-- @field array_table#object _enqueueArray 用于进队列的数据的数组
M._enqueueArray = nil
-- @field #int _enqueueCount 进队列数组长度
M._enqueueCount = 0

-- 初始化，可加入若干初始数据
-- @param self
-- @param va_list#object ... 
function M:ctor(...)
	self._dequeueArray = {}
	self._enqueueArray = {}
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
	assert(value ~= nil, "the parameter of value is nil")
	if self._dequeueCount == 0 then
		self._dequeueCount = 1
		self._dequeueArray[1] = value
	else
		self._enqueueCount = self._enqueueCount + 1
		self._enqueueArray[self._enqueueCount] = value
	end
end

-- 把一个数据从队列拿出来
-- @param self
-- @return #object
function M:dequeue()
	-- 如果dequeue数组不为空，直接弹出顶部数据
	-- 否则将enqueue反向插入到dequeue数组，再弹出dequeue数组的顶部数据
	local popArray = self._dequeueArray
	if self._dequeueCount == 0 then
		if self._enqueueCount == 0 then
			return nil
		end
		local j = 1
		local pushArray = self._enqueueArray
		for i = self._enqueueCount, 1, - 1 do
			popArray[j] = pushArray[i]
			pushArray[i] = nil
			j = j + 1
		end
		self._dequeueCount = j
	end
	local value = popArray[self._dequeueCount]
	popArray[self._dequeueCount] = nil
	self._dequeueCount = self._dequeueCount - 1
	return value
end

-- 清空队列
-- @param self
function M:clear()
	if self._dequeueCount > 0 then
		self._dequeueArray = {}
		self._dequeueCount = 0
	end
	if self._enqueueCount > 0 then
		self._enqueueArray = {}
		self._enqueueCount = 0
	end
end

-- 是否包含这个值
-- @param self
-- @return #bool
function M:contains(value)
	assert(value ~= nil, "the parameter of value is nil")
	return table.indexof(self._dequeueArray, value) > 0 or table.indexof(self._enqueueArray, value) > 0
end

-- 获取队列的长度
-- @param self
-- @return #int
function M:count()
	return self._dequeueCount + self._enqueueCount
end

-- 队列的迭代器
-- @param self
-- @parna #int 索引
-- @return #int 索引
-- @return #object 值
local function _iterator(self, index)
	-- 如果index>0，则从dequeue数组遍历
	-- 如果index<=0 and index>-enqueueCount，则从enqueue数组遍历
	-- 否则遍历完毕
	if index > 0 then
		return index - 1, self._dequeueArray[index]
	elseif index > - self._enqueueCount then
		return index - 1, self._enqueueArray[- index + 1]
	else
		return nil
	end
end

-- 获取队列的迭代器，从加进队列的顺序排序
-- @param self
-- @return #function 迭代函数
-- @return #ArrayQueue 队列
-- @return #int 索引
function M:iterator()
	return _iterator, self, self._dequeueCount
end

-- 队列是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self._dequeueCount == 0 and self._enqueueCount == 0
end

-- 浅克隆队列
-- @param self
-- @return #ArrayQueue
function M:clone()
	local result = M.new()
	local resultPopArray = result._dequeueArray
	local currentPushArray = self._enqueueArray
	local j = 0
	for i = self._enqueueCount, 1, - 1 do
		j = j + 1
		resultPopArray[j] = currentPushArray[i]
	end
	for _, value in ipairs(self._dequeueArray) do
		j = j + 1
		resultPopArray[j] = value
	end
	result._dequeueCount = j
	return result
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString()
	local temp = {}
	local j = 0
	for _, v in ipairs(self._dequeueArray) do
		j = j + 1
		temp[j] = tostring(v)
	end
	local currentPushArray = self._enqueueArray
	for i = self._enqueueCount, 1, - 1 do
		j = j + 1
		temp[j] = tostring(currentPushArray[i])
	end
	return string.format("%s[%s]", tostring(self), table.concat(temp, ","))
end

return M 