local type = type
local assert = assert
local table = table
local ipairs = ipairs
local string = string

-- 数据列表封装，因为有缓存table的长度，所以获取长度和插入数组尾部和移除尾部会性能较好
local M = class("ArrayList", import(".List", ...))

-- @field array_table#object _arr 存放数组数据
M._arr = nil
-- @field #int _count 数据长度
M._count = 0

-- 初始化，可加入若干初始数据
-- @param self
-- @param va_list#object ... 
function M:ctor(...)
	self._arr = {}
	return self:adds(...)
end

-- 将一个table纳入到数组管理
-- @param self
-- @param array_table#object arr
function M:pack(arr)
	self._arr = arr
	self._count = #arr
end 

-- 向数组添加一个值
-- @param self
-- @param #object value 
function M:add(value)
	assert(value ~= nil, "the parameter of value is nil")
	local count = self._count + 1
	self._count = count
	self._arr[count] = value
end

-- 向数组添加多个值
-- @param self
-- @param va_list#object ... 
function M:adds(...)
	local count = self._count
	for _, value in ipairs {...} do
		count = count + 1
		self._arr[count] = value
	end
	self._count = count
end

-- 清空数组
-- @param self
function M:clear()
	if self._count == 0 then
		return
	end
	if self._count > 16 then 
		self._arr = {}
	else 
		local arr = self._arr
		for i, value in ipairs(arr) do
			arr[i] = nil
		end
	end 
	self._count = 0
end

function M:clearByFunc(func)
	if self._count == 0 then 
		return 
	end 
	if not func then 
		return self:clear()
	end 
	local arr = self._arr
	for i, value in ipairs(arr) do
		arr[i] = nil
		func(value)
	end
	self._count = 0
end 

-- 是否包含这个值
-- @param self
-- @param #object value 
-- @return #boolean
function M:contains(value)
	assert(value ~= nil, "the parameter of value is nil")
	return self:indexOf(value) > 0
end

-- 获取数组大小
-- @param self
-- @return #int
function M:count()
	return self._count
end

-- 获取数组的迭代器
-- @param self
-- @return #function 迭代函数
-- @return array_table#object 数组容器
-- @return #int 索引
function M:iterator()
	return ipairs(self._arr)
end

-- 数组是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self._count == 0
end

-- 浅克隆数组
-- @param self
-- @return #ArrayList
function M:clone()
	local result = M.new()
	local arr = result._arr
	for i, value in ipairs(self._arr) do
		arr[i] = value
	end
	result._count = self._count
	return result
end

-- 通过索引获取数组数据
-- @param self
-- @param #int index 
-- @return #object
function M:get(index)
	assert(type(index) == "number", string.format("the parameter of index:%s is not a number", tostring(index)))
	assert(index > 0 and index <= self._count, string.format("the parameter of index:%i is out of boundary", index))
	return self._arr[index]
end

-- 获取数组最前的值
-- @param self
-- @return #object
function M:getFirst()
	return self._arr[1]
end

-- 获取数组最后的值
-- @param self
-- @return #object
function M:getLast()
	return self._arr[self._count]
end

-- 通过索引设置数组数据，并返回旧值
-- @param self
-- @param #int index 
-- @param #object value 
-- @return #object
function M:set(index, value)
	assert(type(index) == "number", string.format("the parameter of index:%s is not a number", tostring(index)))
	assert(index > 0 and index <= self._count, string.format("the parameter of index:%i is out of boundary", index))
	assert(value ~= nil, "the parameter of value is nil")
	local origin = self._arr[index]
	self._arr[index] = value
	return origin
end

-- 根据排序方法对数组排序
-- @param self
-- @param #function comp 
function M:sort(comp)
	assert(type(comp) == "function", string.format("the parameter of comp:%s is not a function", tostring(comp)))
	if self._count <= 1 then
		return
	end
	-- 使用table的快排
	return table.sort(self._arr, comp)
end

-- 反转数组
-- @param self
function M:reverse()
	local count = self._count
	if count <= 1 then
		return
	end
	local arr = self._arr
	for i = 1, math.floor(count / 2) do
		local target = count - i + 1
		local temp = arr[i]
		arr[i] = arr[target]
		arr[target] = temp
	end
end

-- 根据值获取它所在的索引，从数组前面找起
-- @param self
-- @param #object value 
-- @return #int
function M:indexOf(value)
	assert(value ~= nil, "the parameter of value is nil")
	for i, v in ipairs(self._arr) do
		if v == value then
			return i
		end
	end
	return 0
end

-- 根据值获取它所在的索引，从数组后面找起
-- @param self
-- @param #object value 
-- @return #int
function M:lastIndexOf(value)
	assert(value ~= nil, "the parameter of value is nil")
	local arr = self._arr
	for i = self._count, 1, - 1 do
		if arr[i] == value then
			return i
		end
	end
	return 0
end

-- 从数组的后面插入值
-- @param self
-- @param #object value 
function M:addLast(value)
	return self:add(value)
end

-- 从数组的前面插入值
-- @param self
-- @param #object value 
function M:addFirst(value)
	return self:insert(1, value)
end

-- 根据索引，向数组插入这个值
-- @param self
-- @param #int index 
-- @param #object value 
function M:insert(index, value)
	assert(type(index) == "number", string.format("the parameter of index:%s is not a number", tostring(index)))
	assert(value ~= nil, "the parameter of value is nil")
	local count = self._count + 1
	assert(index > 0 and index <= count, string.format("the parameter of index:%i is out of boundary", index))
	if index == count then
		return self:add(value)
	else
		self._count = count
		return table.insert(self._arr, index, value)
	end
end

-- 从数组移除值
-- @param self
-- @param #object value 
-- @param #boolean removeall 是否移除所有与这个值相等
function M:removeByValue(value, removeall)
	assert(value ~= nil, "the parameter of value is nil")
	if self._count == 0 then
		return
	end
	local arr = self._arr
	for i = self._count, 1, - 1 do
		if arr[i] == value then
			self._count = count - 1
			table.remove(self._arr, i)
			if not removeall then break end
		end
	end
end

-- 通过比较，从数组移除值
-- @param self
-- @param #function func 如果返回true，则移除
-- @param #boolean removeall 是否移除所有与这个值相等
function M:removeByFunc(func, removeAll)
	assert(type(func) == "function", string.format("the parameter of func:%s is not function", tostring(func)))
	if self._count == 0 then
		return
	end
	local arr = self._arr
	for i = self._count, 1, - 1 do
		if func(arr[i]) then
			self._count = count - 1
			table.remove(self._arr, i)
			if not removeall then break end
		end
	end
end

-- 通过索引移除值，并返回旧值
-- @param self
-- @param #int index 
-- @return #object
function M:removeAt(index)
	assert(type(index) == "number", string.format "the parameter of index:%s is not a number", tostring(index))
	local count = self._count
	assert(index > 0 and index <= count, string.format("the parameter of index:%i is out of boundary", index))
	if count == 0 then
		return
	end
	if index == count then
		return self:removeLast()
	else
		self._count = count - 1
		return table.remove(self._arr, index)
	end
end

-- 从数组的前面移除值，并返回这个值
-- @param self
-- @return #object
function M:removeFirst()
	return self:removeAt(1)
end

-- 从数组的后面移除值，并返回这个值
-- @param self
-- @return #object
function M:removeLast()
	if self._count == 0 then
		return
	end
	local count = self._count
	local value = self._arr[count]
	self._count = count - 1
	self._arr[count] = nil
	return value
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString()
	local temp = {}
	for i, v in ipairs(self._arr) do
		temp[i] = tostring(v)
	end
	return string.format("%s[%s]", tostring(self), table.concat(temp, ","))
end

return M
