-- hash表，比直接使用table的好处是封装了对表的数量访问
local M = class("HashMap")

-- @field _map #table 存放数据的table表
M._map = nil
-- @field _count #int table表的长度
M._count = 0

-- 初始化table
-- @param self
function M:ctor()
	self._map = {}
end

-- 对table的一个key设值
-- @param self
-- @param #object key 键
-- @param #object value 值 如果值为空，则等价于移除这个键值
-- @return #object 返回这个键的旧值
function M:set(key, value)
	assert(key ~= nil, "the parameter of key is nil")
	local origin = self._map[key]
	if not origin then
		if value ~= nil then
			self._count = self._count + 1
		else
			self._count = self._count - 1
		end
	end
	self._map[key] = value
	return origin
end

-- 获取一个key的值
-- @param self
-- @param #object key 键
-- @return #object 返回这个键值
function M:get(key)
	assert(key ~= nil, "the parameter of key is nil")
	return self._map[key]
end

-- 移除一个key值
-- @param self
-- @param #object key 键
-- @return #object 返回这个键值
function M:remove(key)
	assert(key ~= nil, "the parameter of key is nil")
	local origin = self._map[key]
	if not origin then
		return
	end
	self._count = self._count - 1
	self._map[key] = nil
	return origin
end

-- 清空hash表
-- @param self
function M:clear()
	if self._count == 0 then
		return
	end
	self._count = 0
	self._map = {}
end

-- 是否包含这个键
-- @param self
-- @return #bool
function M:containsKey(key)
	assert(key ~= nil, "the parameter of key is nil")
	return self._map[key] ~= nil
end

-- 是否包含这个值
-- @param self
-- @return #bool
function M:containsValue(value)
	assert(value ~= nil, "the parameter of value is nil")
	for _, v in pairs(self._map) do
		if v == value then
			return true
		end
	end
	return false
end

-- 获取表的大小
-- @param self
-- @return #int
function M:count()
	return self._count
end

-- 获取表的迭代器
-- @param self
-- @return #function 迭代函数
-- @return #table 表
-- @return #object 键
function M:iterator()
	return pairs(self._map)
end

-- 表是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self._count == 0
end

-- 浅克隆hash表
-- @param self
-- @return #HashMap
function M:clone()
	local result = M.new()
	local map = result._map
	for k, v in pairs(self._map) do
		map[k] = v
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
	for k, v in pairs(self._map) do
		i = i + 1
		temp[i] = string.format("%s:%s", tostring(k), tostring(v))
	end
	return string.format("%s{%s}", tostring(self), table.concat(temp, ","))
end

return M 