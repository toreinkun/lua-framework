-- 列表容器
local M = class("List", import(".Collection", ...))

-- 通过索引获取列表数据
-- @param self
-- @param #int index
-- @return #object
function M:get(index) end

-- 获取列表最前的值
-- @param self
-- @return #object
function M:getFirst() end

-- 获取列表最后的值
-- @param self
-- @return #object
function M:getLast() end

-- 通过索引设置列表数据，并返回旧值
-- @param self
-- @param #int index 
-- @param #object value 
-- @return #object
function M:set(index, value) end

-- 根据排序方法对列表排序
-- @param self
-- @param #function comp 
function M:sort(comp) end

-- 反转列表
-- @param self
function M:reverse() end

-- 根据值获取它所在的索引，从列表前面找起
-- @param self
-- @param #object value 
-- @return #int
function M:indexOf(value) end

-- 根据值获取它所在的索引，从列表后面找起
-- @param self
-- @param #object value 
-- @return #int
function M:lastIndexOf(value) end

-- 从列表的后面插入值
-- @param self
-- @param #object value 
function M:addLast(value) end

-- 从列表的前面插入值
-- @param self
-- @param #object value 
function M:addFirst(value) end

-- 根据索引，向列表插入这个值
-- @param self
-- @param #int index 
-- @param #object value
function M:insert(index, value) end

-- 从列表移除一个值
-- @param self
-- @param #object value 
function M:remove(value)
	return self:removeByValue(value)
end

-- 从列表移除值
-- @param self
-- @param #object value 
-- @param #boolean removeall 是否移除所有与这个值相等
function M:removeByValue(value, removeall) end

-- 通过比较，从列表移除值
-- @param self
-- @param #function func 如果返回true，则移除
-- @param #boolean removeall 是否移除所有与这个值相等
function M:removeByFunc(func, removeAll) end

-- 通过索引移除值，并返回旧值
-- @param self
-- @param #int index 
-- @return #object
function M:removeAt(index) end

-- 从列表的前面移除值，并返回这个值
-- @param self
-- @return #object
function M:removeFirst() end

-- 从列表的后面移除值，并返回这个值
-- @param self
-- @return #object
function M:removeLast() end

return M
