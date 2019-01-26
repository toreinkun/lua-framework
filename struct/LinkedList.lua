local type = type
local assert = assert
local ipairs = ipairs
local string = string

-- 链表节点
local Node = {}
-- @field #Node _previous 前节点
Node._previous = nil
-- @field #Node _next 后节点
Node._next = nil
-- @field #object _value 数据
Node._value = nil

-- 链表容器
local M = class("LinkedList", import(".List", ...))

-- @field #Node _head 链表头，不存放数据
M._head = nil
-- @field #int _count 链表容器大小
M._count = 0

-- @field array_table#Node _nodePoolInstance 链表节点对象池实例
M._nodePoolInstance = nil
-- @field #int _nodePoolSize 链表节点对象池大小
M._nodePoolSize = 0

-- 新建一个节点
-- @param self
-- @return #Node
local function _newNode(self)
	local nodePoolSize = self._nodePoolSize
	if nodePoolSize > 0 then
		self._nodePoolSize = nodePoolSize - 1
		return self._nodePoolInstance[nodePoolSize]
	else
		return {}
	end
end

-- 插入一个节点
-- @param self
-- @param #object value 值
-- @param #Node previous 前节点
-- @param #Node next 后节点
local function _insertNode(self, value, previous, next)
	local node = _newNode(self)
	node._value = value
	node._previous = previous
	node._next = next
	-- 设置前节点的后节点
	previous._next = node
	-- 设置后节点的前节点
	next._previous = node
end

-- 返还一个节点
-- @param self
-- @param #Node node 
local function _returnNode(self, node)
	self._nodePoolSize = self._nodePoolSize + 1
	self._nodePoolInstance[self._nodePoolSize] = node
end

-- 移除一个节点，并返回该节点的值
-- @param #Node node
-- @return #object
local function _removeNode(self, node)
	local previous = node._previous
	local next = node._next
	-- 设置前节点的后节点
	previous._next = next
	-- 设置后节点的前节点
	next._previous = previous
	
	_returnNode(self, node)
	return node._value
end

-- 根据值，获取所在的节点
-- @param self
-- @param #object value
-- @return #Node
local function _getNodeWithValue(self, value)
	local head = self._head
	local current = head._next
	while current ~= head do
		if current._value == value then
			return current
		end
		current = current._next
	end
	return nil
end

-- 根据索引，获取所在的节点
-- @param self
-- @param #object value
-- @return #Node
local function _getNodeAtIndex(self, index)
	local current = self._head
	-- 索引在链表前面，则从前往后，否则从后往前
	if index <= self._count / 2 then
		for i = 1, index do
			current = current._next
		end
	else
		for i = 1, self._count - index + 1 do
			current = current._previous
		end
	end
	return current
end

-- 初始化，可加入若干初始数据
-- @param self
-- @param va_list#object ... 
function M:ctor(...)
	local head = _newNode(self)
	head._next = head
	head._previous = head
	self._head = head
	self._count = 0
	self._nodePoolInstance = {}
	return self:adds(...)
end

-- 向链表添加一个值
-- @param self
-- @param #object value 
function M:add(value)
	assert(value ~= nil, "the parameter of value is nil")
	self._count = self._count + 1
	local head = self._head
	return _insertNode(self, value, head._previous, head)
end

-- 向链表添加多个值
-- @param self
-- @param va_list#object ... 
function M:adds(...)
	for _, value in ipairs {...} do
		self:add(value)
	end
end

-- 从链表的后面插入值
-- @param self
-- @param #object value 
function M:addLast(value)
	return self:add(value)
end

-- 从链表的前面插入值
-- @param self
-- @param #object value 
function M:addFirst(value)
	assert(value ~= nil, "the parameter of value is nil")
	self._count = self._count + 1
	local head = self._head
	return _insertNode(self, value, head, head._next)
end

-- 是否包含这个值
-- @param self
-- @param #object value
-- @return #boolean
function M:contains(value)
	assert(value ~= nil, "the parameter of value is nil")
	return self:indexOf(value) > 0
end

-- 通过索引获取链表数据
-- @param self
-- @param #int index
-- @return #object
function M:get(index)
	assert(type(index) == "number", string.format("the parameter of index:%s is not a number", tostring(index)))
	assert(index > 0 and index <= self._count, string.format("the parameter of index:%i is out of boundary", index))
	return _getNodeAtIndex(self, index)._value
end

-- 通过索引设置链表数据，并返回旧值
-- @param self
-- @param #int index
-- @param #object value
-- @return #object
function M:set(index, value)
	assert(type(index) == "number", string.format("the parameter of index:%s is not a number", tostring(index)))
	assert(index > 0 and index <= self._count, string.format("the parameter of index:%i is out of boundary", index))
	assert(value ~= nil, "the parameter of value is nil")
	local node = _getNodeAtIndex(self, index)
	local origin = node._value
	node._value = value
	return origin
end

-- 根据索引，向链表插入这个值
-- @param self
-- @param #int index
-- @param #object value 
function M:insert(index, value)
	assert(type(index) == "number", string.format("the parameter of index:%s is not a number", tostring(index)))
	assert(value ~= nil, "the parameter of value is nil")
	assert(index > 0 and index <= self._count + 1, string.format("the parameter of index:%i is out of boundary", index))
	local node = _getNodeAtIndex(self, index)
	if node == nil then
		return
	end
	self._count = self._count + 1
	return _insertNode(self, value, node._previous, node)
end

function M:insertByFunc(func, value)
	if self._count == 0 then
		return func(value) and self:addLast(value)
	end
	
	local head = self._head
	local current = head._next
	while current ~= head do
		if func(value, current._value) then
			self._count = self._count + 1
			_insertNode(self, value, current._previous, current)
			return
		end
		current = current._next
	end
end

-- 通过链表移除值，并返回旧值
-- @param self
-- @param #int index
-- @return #object
function M:removeAt(index)
	assert(type(index) == "number", string.format("the parameter of index:%s is not a number", tostring(index)))
	local count = self._count
	assert(index > 0 and index <= count, string.format("the parameter of index:%i is out of boundary", index))
	if count == 0 then
		return
	end
	local node = _getNodeAtIndex(self, index)
	if node == nil then
		return
	end
	self._count = count - 1
	return _removeNode(self, node)
end

-- 从链表的前面移除值，并返回这个值
-- @param self
-- @return #object
function M:removeFirst()
	if self._count == 0 then
		return
	end
	self._count = self._count - 1
	return _removeNode(self, self._head._next)
end

-- 从链表的后面移除值，并返回这个值
-- @param self
-- @return #object
function M:removeLast()
	if self._count == 0 then
		return
	end
	self._count = self._count - 1
	return _removeNode(self, self._head._previous)
end

-- 从链表移除值
-- @param self
-- @param #object value
-- @param #boolean removeall 是否移除所有与这个值相等
function M:removeByValue(value, removeAll)
	assert(value ~= nil, "the parameter of value is nil")
	
	if self._count == 0 then
		return
	end
	
	local head = self._head
	local current = head._next
	while current ~= head do
		if value == current._value then
			self._count = self._count - 1
			_removeNode(self, current)
			if not removeAll then break end
		end
		current = current._next
	end
end

-- 通过比较，从链表移除值
-- @param self
-- @param #function func 如果返回true，则移除
-- @param #boolean removeall 是否移除所有与这个值相等
function M:removeByFunc(func, removeAll)
	assert(type(func) == "function", string.format("the parameter of func:%s is not function", tostring(func)))
	
	if self._count == 0 then
		return
	end
	
	local head = self._head
	local current = head._next
	while current ~= head do
		if func(current._value) then
			self._count = self._count - 1
			_removeNode(self, current)
			if not removeAll then break end
		end
		current = current._next
	end
end

-- 清空链表
-- @param self
function M:clear()
	if self._count == 0 then
		return
	end
	local head = self._head
	local current = head._next
	while current ~= head do
		_returnNode(self, current)
		current = current._next
	end
	head._next = head
	head._previous = head
	self._count = 0
end

-- 获取链表大小
-- @param self
-- @return #int
function M:count()
	return self._count
end

-- 链表是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	return self._count == 0
end

-- 获取链表最前的值
-- @param self
-- @return #object
function M:getFirst()
	return self._head._next._value
end

-- 获取链表最后的值
-- @param self
-- @return #object
function M:getLast()
	return self._head._previous._value
end

-- 根据值获取它所在的索引，从链表前面找起
-- @param self
-- @param #object value
-- @return #int
function M:indexOf(value)
	assert(value ~= nil, "the parameter of value is nil")
	if self._count == 0 then
		return 0
	end
	local index = 1
	for _, v in self:iterator() do
		if v == value then
			return index
		end
		index = index + 1
	end
	return 0
end

-- 根据值获取它所在的索引，从链表后面找起
-- @param self
-- @param #object value
-- @return #int
function M:lastIndexOf(value)
	assert(value ~= nil, "the parameter of value is nil")
	if self._count == 0 then
		return 0
	end
	local index = self._count
	local head = self._head
	local current = head._previous
	while current ~= head do
		if current._value == value then
			return index
		end
		index = index - 1
		current = current._previous
	end
	return 0
end

-- 反转链表
-- @param self
function M:reverse()
	if self._count <= 1 then
		return
	end
	local head = self._head
	local current = head._next
	local previous = head
	while current ~= head do
		local next = current._next
		previous._previous = current
		current._next = previous
		previous = current
		current = next
	end
	head._next = previous
	previous._previous = head
end

-- 链表迭代器
-- @param #Node head 头节点
-- @param #Node current 当前节点
-- @return #Node 下一个节点
-- @return #object 当前节点的值
local function _iterator(head, current)
	if current == head then
		return nil
	else
		return current._next, current._value
	end
end

-- 获取链表的迭代器
-- @param self
-- @return #function 迭代函数
-- @return #Node 头节点
-- @return #Node 第一个节点
function M:iterator()
	local head = self._head
	return _iterator, head, head._next
end

-- 浅克隆链表
-- @param self
-- @return #LinkedList
function M:clone()
	local result = M.new()
	for _, v in self:iterator() do
		result:add(v)
	end
	return result
end

-- 把源节点抽出来，添加到目标节点后面，并返回源节点的前一个节点
-- @param #Node srcNode
-- @param #Node destNode
-- @return #Node
local function _moveToBack(srcNode, destNode)
	-- 抽出left节点
	local temp = srcNode._previous
	temp._next = srcNode._next
	srcNode._next._previous = temp
	-- 插入节点到right的后面
	srcNode._previous = destNode
	srcNode._next = destNode._next
	destNode._next._previous = srcNode
	destNode._next = srcNode
	
	return temp
end

-- 归并排序左右区间，并返回区间的最后一个节点
-- @param #function comp
-- @param #Node leftNode
-- @param #Node rightNode
-- @param #int space 空间大小
-- @return #Node
local function _sort(comp, leftNode, leftIndex, rightNode, rightIndex)
	-- 标识区间的最后一个节点
	local lastNode = rightNode
	if comp(leftNode._value, rightNode._value) then
		rightIndex = rightIndex - 1
		rightNode = rightNode._previous
	else
		leftIndex = leftIndex - 1
		-- 最后一个节点更新为左区间的最右的节点
		lastNode = leftNode
		leftNode = _moveToBack(leftNode, rightNode)
	end
	while leftIndex > 0 and rightIndex > 0 do
		if comp(leftNode._value, rightNode._value) then
			rightIndex = rightIndex - 1
			rightNode = rightNode._previous
		else
			leftIndex = leftIndex - 1
			leftNode = _moveToBack(leftNode, rightNode)
		end
	end
	return lastNode
end

-- 根据排序方法对链表排序
-- @param self
-- @param #function comp 
function M:sort(comp)
	assert(type(comp) == "function", string.format("the parameter of comp:%s is not a function", tostring(comp)))
	local count = self._count
	if count <= 1 then
		return
	end
	-- 使用归并排序
	local head = self._head
	local gap = 1
	while gap < count do
		local left, right = head, head
		for i = 1, count - gap, 2 * gap do
			for j = 1, gap do
				left = left._next
			end
			right = left
			local rgap = gap
			for j = 1, gap do
				local next = right._next
				if next == head then
					rgap = j - 1
					break
				end
				right = next
			end
			local last = _sort(comp, left, gap, right, rgap)
			left, right = last, last
		end
		gap = 2 * gap
	end
end

-- 输出容器内容
-- @param self
-- @return #string
function M:toString()
	local temp = {}
	local i = 1
	for _, v in self:iterator() do
		temp[i] = tostring(v)
		i = i + 1
	end
	return string.format("%s[%s]", tostring(self), table.concat(temp, ","))
end

return M 