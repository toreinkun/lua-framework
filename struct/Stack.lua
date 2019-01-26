-- 栈容器，先进后出原则
local M = class("Stack", pool.ObjectReusable)

-- @field array_table#object _stack 存放栈数据的数组
M._stack = nil
-- @field #int _count 栈的大小
M._count = 0

-- 初始化，可加入若干初始数据
-- @param self
-- @param va_list#object ... 
function M:ctor(...)
	self._stack = {}
	self:pushs(...)
end

-- 向栈压入多个值
-- @param self
-- @param va_list#object ... 
function M:pushs(...)
	local i = self._count
	for _, value in ipairs {...} do
		i = i + 1
		self._stack[i] = value
	end
	self._count = i
end

-- 向栈压入一个值
-- @param self
-- @param #object value
function M:push(value)
	assert(value ~= nil, "the parameter of value is nil")
	local count = self._count + 1
	self._count = count
	self._stack[count] = value
end

-- 从栈弹出一个值
-- @param self
-- @return #object
function M:pop()
	if self._count == 0 then
		return
	end
	local count = self._count
	local value = self._stack[count]
	self._count = count - 1
	self._stack[count] = nil
	return value
end

-- 清空栈
-- @param self
function M:clear()
	if self._count == 0 then
		return
	end
	self._count = 0
	self._stack = {}
end

-- 是否包含这个值
-- @param self
-- @param #object value 
-- @return #boolean
function M:contains(value)
	return table.indexof(self._stack, value) > 0
end

-- 获取栈大小
-- @param self
-- @return #int
function M:count()
	return self._count
end

-- 栈的迭代函数
-- @return array_table#object stack 栈的table容器
-- @return #int index 索引
local function _iterator(stack, index)
	if index == 0 then
		return nil
	else
		return index - 1, stack[index]
	end
end

-- 获取栈的迭代器，从栈顶到栈底迭代
-- @param self
-- @return #function 迭代函数
-- @return array_table#object
-- @return #int
function M:iterator()
	return _iterator, self._stack, self._count
end

-- 栈是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self._count == 0
end

-- 浅克隆栈
-- @param self
-- @return #Stack
function M:clone()
	local result = M.new()
	local stack = result._stack
	local i = 1
	for _, value in ipairs(self._stack) do
		i = i + 1
		stack[i] = value
	end
	result._count = i
	return result
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString() 
	local temp = {}
	for i, v in ipairs(self._stack) do
		temp[i] = tostring(v)
	end
	return string.format("%s[%s]", tostring(self), table.concat(temp, ","))
end

-- 重用重新加载值
-- @param self
-- @param va_list#object ... 
function M:reuse(...)
	return self:pushs(...)
end

-- 回收清空队列
-- @param self
function M:recycle()
	return self:clear()
end

return M 