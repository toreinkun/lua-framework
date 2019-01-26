local floor = math.floor
local ipairs = ipairs

-- 堆的数据结构
local M = class("Heap", pool.ObjectReusable)
-- @field array_table#int _heap 存放堆数据的数组
M._heap = nil
-- @field #int _count 堆大小
M._count = 0
-- @field function(#object,#object) _sort 堆数据的元素比较函数，如果返回true，则第一个参数要成为第二个参数父节点（第一个参数上浮，第二个参数下沉）
M._sort = nil

-- fixup目标索引
-- @param self
-- @param #int childIndex
local function _fixUp(self, childIndex)
	-- 已经是根节点了，不需要上浮
	if childIndex <= 1 then
		return
	end
	local heap = self._heap
	local sort = self._sort
	local childValue = heap[childIndex]
	while childIndex > 1 do
		local parentIndex = floor(childIndex / 2)
		local parentValue = heap[parentIndex]
		if not sort(childValue, parentValue) then
			break
		end
		heap[childIndex] = parentValue
		childIndex = parentIndex
	end
	heap[childIndex] = childValue
end

-- sitdown目标索引
-- @param self
-- @param #int parentIndex
local function _sitDown(self, parentIndex)
	local heap = self._heap
	local count = self._count
	local minParentIndex = floor(count / 2)
	-- 这个节点没有孩子节点，不需要下沉了
	if parentIndex > minParentIndex then
		return
	end
	local sort = self._sort
	local parentValue = heap[parentIndex]
	while parentIndex <= minParentIndex do
		local childIndex = parentIndex * 2
		local childValue = heap[childIndex]
		local rightIndex = childIndex + 1
		if rightIndex <= count then
			local rightValue = heap[rightIndex]
			if sort(rightValue, childValue) then
				childIndex = rightIndex
				childValue = rightValue
			end
		end
		if not sort(childValue, parentValue) then
			break
		end
		heap[parentIndex] = childValue
		parentIndex = childIndex
	end
	heap[parentIndex] = parentValue
end

-- 堆初始化
-- @param self
function M:ctor(sort)
	self._heap = {}
	self._sort = sort
end

-- 向堆底插入数据，然后fixup
-- @param self
-- @param #object value 
function M:push(value)
	self._count = self._count + 1
	self._heap[self._count] = value
	return _fixUp(self, self._count)
end

-- 向堆底插入多个值，每插入一个，fixup一次
-- @param self
-- @param va_list#object ... 
function M:pushs(...)
	for _, value in ipairs {...} do
		self:push(value)
	end
end 

-- 替换堆顶数据，然后sitdown
-- @param self
-- @param #object value 
function M:replaceTop(value)
	self._heap[1] = value
	_sitDown(self, 1)
end

-- 获取堆顶数据
-- @param self
-- @return #object
function M:top()
	return self._heap[1]
end

-- 弹出堆顶数据，再把堆底的数据移动到堆顶，然后sitdown
-- @param self
-- @return #object
function M:pop()
	local count = self._count
	if count == 0 then
		return
	end
	local heap = self._heap
	heap[1] = heap[count]
	self._count = count - 1
	heap[count] = nil
	return _sitDown(self, 1)
end

-- 清空堆
-- @param self
function M:clear()
	if self._count == 0 then
		return
	end
	self._count = 0
	self._heap = {}
end

-- 获取堆的大小
-- @param self
-- @return #int
function M:count()
	return self._count
end

-- 获取堆的迭代器
-- @param self
-- @return #function
-- @return #table
-- @return #number
function M:iterator()
	return ipairs(self._heap)
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString()
	local temp = {}
	for i, v in ipairs(self._heap) do
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
