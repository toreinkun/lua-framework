-- 容器集合接口
local M = class("Collection", pool.ObjectReusable)

-- 向容器添加一个值
-- @param self
-- @param #object value 
function M:add(value) end

-- 向容器添加多个值
-- @param self
-- @param va_list#object ... 
function M:adds(...) end

-- 从容器移除一个值
-- @param self
-- @param #object value 
function M:remove(value) end

-- 清空容器
-- @param self
function M:clear() end

-- 是否包含这个值
-- @param self
-- @param #object value 
-- @return #boolean
function M:contains(value) end

-- 获取容器大小
-- @param self
-- @return #int
function M:count() end

-- 获取容器的迭代器
-- @param self
-- @return #function 迭代函数
-- @return #object
-- @return #object
function M:iterator() end

-- 容器是否为空
-- @param self
-- @return #boolean
function M:isEmpty() end

-- 浅克隆容器
-- @param self
-- @return #Collection
function M:clone() end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString() end

-- 重用重新加载值
-- @param self
-- @param va_list#object ... 
function M:reuse(...)
	return self:adds(...)
end

-- 回收清空容器
-- @param self
function M:recycle()
	return self:clear()
end

return M 