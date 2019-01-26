-- 队列数据结构接口，先进先出原则
local M = class("Queue", pool.ObjectReusable)

-- 把多个数据加进队列
-- @param self
-- @param va_list#object ... 
function M:enqueues(...) end

-- 把一个数据加进队列
-- @param self
-- @param #object value 
function M:enqueue(value) end

-- 把一个数据从队列拿出来
-- @param self
-- @return #object
function M:dequeue() end

-- 清空队列
-- @param self
function M:clear() end

-- 是否包含这个值
-- @param self
-- @return #bool
function M:contains(value) end

-- 获取队列的长度
-- @param self
-- @return #int
function M:count() end

-- 获取队列的迭代器，从加进队列的顺序排序
-- @param self
-- @return #function 迭代函数
-- @return #object
-- @return #object
function M:iterator() end

-- 队列是否为空
-- @param self
-- @return #boolean
function M:isEmpty() end

-- 浅克隆队列
-- @param self
-- @return #Queue
function M:clone() end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString() end

-- 重用重新加载值
-- @param self
-- @param va_list#object ... 
function M:reuse(...)
	return self:enqueues(...)
end

-- 回收清空队列
-- @param self
function M:recycle()
	return self:clear()
end


return M 