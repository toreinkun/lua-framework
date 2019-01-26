local LinkedList = import(".LinkedList", ...)

-- 用链表实现的队列
local M = class("LinkedQueue", import(".Queue", ...))

-- @field #LinkedList _linkedlist 存放数据的链表
M._linkedlist = nil

-- 初始化，可加入若干初始数据
-- @param self
-- @param va_list#object ... 
function M:ctor(...)
	self._linkedlist = LinkedList.new()
	self:enqueues(...)
end

-- 把多个数据加进队列
-- @param self
-- @param va_list#object ... 
function M:enqueues(...)
	for _, value in ipairs {...} do
		self._linkedlist:addLast(value)
	end
end

-- 把一个数据加进队列
-- @param self
-- @param #object value
function M:enqueue(value)
	return self._linkedlist:addLast(value)
end

-- 把一个数据从队列拿出来
-- @param self
-- @return #object
function M:dequeue()
	return self._linkedlist:removeFirst()
end

-- 清空队列
-- @param self
function M:clear()
	return self._linkedlist:clear()
end

-- 是否包含这个值
-- @param self
-- @return #bool
function M:contains(value)
	return self._linkedlist:contains(value)
end

-- 获取队列的长度
-- @param self
-- @return #int
function M:count()
	return self._linkedlist:count()
end

-- 获取队列的迭代器，从加进队列的顺序排序
-- @param self
-- @return #function 迭代函数
-- @return #object
-- @return #object 
function M:iterator()
	return self._linkedlist:iterator()
end

-- 队列是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self._linkedlist:isEmpty()
end

-- 浅克隆队列
-- @param self
-- @return #LinkedQueue
function M:clone()
	local result = M.new()
	local linkedlist = result._linkedlist
	for _, value in self._linkedlist:iterator() do
		linkedlist:addLast(value)
	end
	return result
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString()
	local temp = {}
	local i = 1
	for _, v in self._linkedlist:iterator() do
		temp[i] = tostring(v)
		i = i + 1
	end
	return string.format("%s[%s]", tostring(self), table.concat(temp, ","))
end

return M 