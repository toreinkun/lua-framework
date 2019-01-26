-- set表，比直接使用table<key,true>的好处是封装了对集合的数量访问
local M = class("HashSet", import(".Collection", ...))

-- @field table<#object,#boolean> _set 存放集合数据的table容器
M._set = nil
-- @field #int _count 集合大小
M._count = 0

-- 初始化，可添加若干初始数据
-- @param self
-- @param va_list#object ... 
function M:ctor(...)
	self._set = {}
	self:adds(...)
end

-- 添加一个值
-- @param self
-- @param #object value 
function M:add(value)
	assert(value ~= nil, "the parameter of value is nil")
	if self._set[value] then
		return
	end
	self._count = self._count + 1
	self._set[value] = true
end

-- 添加多个值
-- @param self
-- @param va_list#object .. 
function M:adds(...)
	for _, value in ipairs({...}) do
		self:add(value)
	end
end

-- 从集合移除一个值
-- @param self
-- @param #object value 
function M:remove(value)
	assert(value ~= nil, "the parameter of value is nil")
	if not self._set[value] then
		return
	end
	self._count = self._count - 1
	self._set[value] = nil
end

-- 清空集合
-- @param self
function M:clear()
	if self._count == 0 then
		return
	end
	self._count = 0
	self._set = {}
end

-- 是否包含这个值
-- @param self
-- @return #bool
function M:contains(value)
	assert(value ~= nil, "the parameter of value is nil")
	return self._set[value] == true
end

-- 获取集合大小
-- @param self
-- @return #int
function M:count()
	return self._count
end

-- 获取集合的迭代器
-- @param self
-- @return #function 迭代函数
-- @return #table 表
-- @return #object 值
function M:iterator()
	return pairs(self._set)
end

-- 集合是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self._count == 0
end

-- 浅克隆集合
-- @param self
-- @return #HashSet
function M:clone()
	local result = M.new()
	local set = result._set
	for value, _ in pairs(self._set) do
		set[value] = true
	end
	result._count = self._count
	return result
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString()
	local temp = {}
	local i = 0
	for v, _ in pairs(self._map) do
		i = i + 1
		temp[i] = tostring(v)
	end
	return string.format("%s[%s]", tostring(self), table.concat(temp, ","))
	
end

return M 