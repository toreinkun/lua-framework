local CURRENT_MODULE_NAME = ...
local require = require
local type = type
local getmetatable = getmetatable

-- 给函数添加切面，可监听它的调用前、调用后或替换源函数的实现，但源函数的返回值最大个数是4个
local M = class("AopUtils")

-- 切面的类型，分别是调用前、替换、调用后
local AopType = import(".AopType", CURRENT_MODULE_NAME)

-- 切面上的一个监听封装
local Aspect = {}
-- @field #function _callback 回调函数
Aspect._callback = nil
-- @field #boolean _register 是否可用
Aspect._register = true
-- @field #int _tag 标签
Aspect._tag = 0

-- 一种类型的切面上的所有监听的容器
local Container = class("Container")
-- @field array_table#Aspect _aspects 切面监听数组
Container._aspects = nil
-- @field #boolean _existsRemove 在切面调用的过程中，是否存在删除监听
Container._existsRemove = false
-- @field array_table#Aspect _toAddAspects 在切面调用的过程中，新增的监听
Container._toAddAspects = nil
-- @field #int _inCalling 是否正在切面调用中
Container._inCalling = 0
-- @field #int _currentTag 当前标签
Container._currentTag = 0

function Container:ctor()
	self._aspects =	{}
end

-- 用于替换源函数的位置的对象，然后这个对象实现了call方法 
local AopObject = class("AopObject")
-- @field #function _originFunc 源函数
AopObject._originFunc = nil
-- @field #function _replaceAspect 替换函数
AopObject._replaceAspect = nil
-- @field #Container _preContainer 调用前切面容器
AopObject._preContainer = nil
-- @field #Container _postContainer 调用后切面容器
AopObject._postContainer = nil

-- 调用一种类型的切面容器
-- @param #Container container 切面容器
-- @param #va_list ... 源函数的调用参数
local function _callContainer(container, ...)
	container._inCalling = container._inCalling + 1
	local aspects = container._aspects
	for _, aspect in ipairs(aspects) do
		if aspect._register then
			aspect._callback(...)
		end
	end
	container._inCalling = container._inCalling - 1
	if container._inCalling > 0 then
		return
	end
	-- 移除不可用监听
	if container._existsRemove then
		for i = #aspects, 1, - 1 do
			if not aspects[i]._register then
				table.remove(aspects, i)
			end
		end
	end
	-- 插入新的监听
	if container._toAddAspects then
		for _, aspect in ipairs(container._toAddAspects) do
			table.insert(aspects, aspect)
		end
		container._toAddAspects = nil
	end
end

-- 给容器插入新的监听
-- @param #Container container 
-- @param #function callback 
local function _insertAspect(container, callback)
	container._currentTag = container._currentTag + 1
	if container._inCalling > 0 then
		if not container._toAddAspects then
			container._toAddAspects = {}
		end
		table.insert(container._toAddAspects, {_callback = callback, _register = true, tag = container._currentTag})
	else
		table.insert(container._aspects, {_callback = callback, _register = true, tag = container._currentTag})
	end
	return container._currentTag
end

-- 从容器删除监听
-- @param #Container container 
-- @param #function callback 
-- @param #boolean removeall 是否移除所有
local function _removeAspect(container, callback, removeall)
	if container._inCalling > 0 then
		for _, aspect in ipairs(container._aspects) do
			if aspect._callback == callback then
				aspect._register = false
				if not removeall then return end
			end
		end
	else
		local aspects = container._aspects
		for i = #aspects, 1, - 1 do
			if aspects[i]._callback == callback then
				table.remove(aspects, i)
				if not removeall then return end
			end
		end
	end
end

-- 根据标签，从容器删除监听
-- @param #Container container 
-- @param #int tag 
local function _removeAspectByTag(container, tag)
	if container._inCalling > 0 then
		for _, aspect in ipairs(container._aspects) do
			if aspect._tag == tag then
				aspect._register = false
				return
			end
		end
	else
		local aspects = container._aspects
		for i = #aspects, 1, - 1 do
			if aspects[i]._tag == tag then
				table.remove(aspects, i)
				return
			end
		end
	end
end

-- 元表实现call方法
-- @param self
-- @param #va_list ... 源函数的调用参数
function AopObject.__call(self, ...)
	if self._preContainer then
		_callContainer(self._preContainer, ...)
	end
	local r1, r2, r3, r4
	-- 替换函数
	if self._replaceAspect then
		r1, r2, r3, r4 = self._replaceAspect(...)
	else
		r1, r2, r3, r4 = self._originFunc(...)
	end
	if self._postContainer then
		_callContainer(self._postContainer, ...)
	end
	return r1, r2, r3, r4
end

function AopObject:ctor(originFunc)
	self._originFunc = originFunc
end

-- 对切面插入新的监听
-- @param self
-- @param #AopType aopType 切面类型
-- @param #function callback 回调函数
function AopObject:insertAspect(aopType, callback)
	assert(type(callback) == "function", string.format("the parameter of callback:%s is not function", tostring(callback)))
	if aopType == AopType.Pre then
		if not self._preContainer then
			self._preContainer = Container.new()
		end
		return _insertAspect(self._preContainer, callback)
	elseif aopType == AopType.Post then
		if not self._postContainer then
			self._postContainer = Container.new()
		end
		return _insertAspect(self._postContainer, callback)
	elseif aopType == AopType.Replace then
		self._replaceAspect = callback
	else
		assert(false, string.format("the aop type:%s is invalid", tostring(aopType)))
	end
end

-- 从切面删除监听
-- @param self
-- @param #AopType aopType 切面类型
-- @param #function callback 回调函数
-- @param #boolean removeall 是否移除所有
function AopObject:removeAspect(aopType, callback, removeall)
	assert(type(callback) == "function", string.format("the parameter of callback:%s is not function", tostring(callback)))
	if aopType == AopType.Pre then
		if not self._preContainer then
			return
		end
		return _removeAspect(self._preContainer, callback, removeall)
	elseif aopType == AopType.Post then
		if not self._postContainer then
			return
		end
		return _removeAspect(self._postContainer, callback, removeall)
	elseif aopType == AopType.Replace then
		self._replaceAspect = nil
	else
		assert(false, string.format("the aop type:%s is invalid", tostring(aopType)))
	end
end

function AopObject:removeAspectByTag(aopType, tag)
	if aopType == AopType.Pre then
		if not self._preContainer then
			return
		end
		return _removeAspectByTag(self._preContainer, tag)
	elseif aopType == AopType.Post then
		if not self._postContainer then
			return
		end
		return _removeAspectByTag(self._postContainer, tag)
	else
		assert(false, string.format("the aop type:%s is invalid", tostring(aopType)))
	end
end

-- 删除切面所有监听
-- @param self
function AopObject:removeAllAspects()
	self._replaceAspect = nil
	self._postContainer = nil
	self._preContainer = nil
end

-- 创建切面，如果传入的已经是切面对象，则直接返回
-- @param aopFunc
-- @return #AopObject
local function _createAopObject(aopFunc)
	if not aopFunc then
		printTraceback()
		return
	end
	local aopFuncType = type(aopFunc)
	if aopFuncType == "function" then
		return AopObject.new(aopFunc)
	elseif aopFuncType == "table" then
		assert(aopFunc.class == AopObject, "the class is not AopContainer")
		return aopFunc
	else
		assert(false, string.format("the type:%s of target is wrong", targetType))
	end
end

-- 获取源函数，如果传入的是函数，则直接返回
-- @param target
-- @return #function
local function _getAopOrigin(target)
	local targetType = type(target)
	if targetType == "table" then
		assert(target.class == AopObject, "the class is not AopContainer")
		return target:getOrigin()
	elseif targetType == "function" then
		return target
	else
		assert(false, string.format("the type:%s of target is wrong", targetType))
	end
end

-- 通过路径和目标，获取切面对象
-- @param #table target 目标
-- @param #string field 路径
-- @return #AopObject
local function _getAopObjectByTarget(target, field)
	local fields = string.split(field, ".")
	local aopFunc = target[fields[1]]
	if fields[2] then
		for i = 2, #fields do
			target = _getAopOrigin(aopFunc)
			if not target then
				return nil
			end
			-- 获取local函数
			local level = 1
			local aopFunc = nil
			while true do
				local name, func = debug.getupvalue(target, i)
				if not name then
					return nil
				end
				if name == field then
					aopFunc = func
					break
				end
				level = level + 1
			end
		end
	end
	if type(aopFunc) == "table" and aopFunc.class == AopObject then
		return aopFunc
	end
end

-- 通过路径和目标，创建切面对象，如果对象已是切面对象，则直接返回
-- @param #table target 目标
-- @param #string field 路径
-- @return #AopObject
local function _createAopObjectByTarget(target, field)
	local fields = string.split(field, ".")
	local aopFunc = target[fields[1]]
	if not fields[2] then
		local object = _createAopObject(aopFunc)
		if object ~= aopFunc then
			target[field] = object
		end
		return object
	end
	
	local level
	for i = 2, #fields do
		target = _getAopOrigin(aopFunc)
		if not target then
			return nil
		end
		-- 获取local函数
		level = 1
		local aopFunc = nil
		while true do
			local name, func = debug.getupvalue(target, i)
			if not name then
				return nil
			end
			if name == field then
				aopFunc = func
				break
			end
			level = level + 1
		end
	end
	-- 设置local函数
	local object = _createAopObject(aopFunc)
	if object and aopFunc ~= object then
		debug.setupvalue(target, level, object)
	end
	return object
end

function M.insertAspectByTarget(target, field, aopType, callback)
	assert(type(target) == "table" or type(target) == "userdata", string.format("the parameter of target:%s is not table or userdata", tostring(target)))
	assert(type(field) == "string", string.format("the parameter of field:%s is not string", tostring(field)))
	assert(type(aopType) == "string", string.format("the parameter of aopType:%s is not string", tostring(aopType)))
	assert(type(callback) == "function", string.format("the parameter of callback:%s is not function", tostring(callback)))
	
	local object = _createAopObjectByTarget(target, field)
	if not object then
		return 0
	end
	return object:insertAspect(aopType, callback)
end

function M.insertAspectByFile(file, field, aopType, callback)
	assert(type(file) == "string", string.format("the parameter of file:%s is not string", tostring(file)))
	local target = require(file)
	return M.insertAspectByTarget(target, field, aopType, callback)
end

function M.removeAllAspectsByTarget(target, field)
	assert(type(target) == "table" or type(target) == "userdata", string.format("the parameter of target:%s is not table or userdata", tostring(target)))	
	assert(type(field) == "string", string.format("the parameter of field:%s is not string", tostring(field)))
	local object = _getAopObjectByTarget(target, field)
	if not object then
		return
	end
	return object:removeAllAspects()
end

function M.removeAllAspectsByFile(file, field)
	assert(type(file) == "string", string.format("the parameter of file:%s is not string", tostring(file)))
	local target = require(file)
	return M.removeAllAspectsByTarget(target, field)
end

function M.removeAspectByTag(target, field, aopType, tag)
	assert(type(target) == "table" or type(target) == "userdata", string.format("the parameter of target:%s is not table or userdata", tostring(target)))	
	assert(type(field) == "string", string.format("the parameter of field:%s is not string", tostring(field)))
	assert(type(aopType) == "string", string.format("the parameter of aopType:%s is not string", tostring(aopType)))
	assert(type(tag) == "number", string.format("the parameter of tag:%s is not number", tostring(tag)))
	
	local object = _getAopObjectByTarget(target, field)
	if not object then
		return
	end
	return object:removeAspectByTag(tag)
end

function M.removeAspectByTarget(target, field, aopType, callback, removeall)
	assert(type(target) == "table" or type(target) == "userdata", string.format("the parameter of target:%s is not table or userdata", tostring(target)))	
	assert(type(field) == "string", string.format("the parameter of field:%s is not string", tostring(field)))
	assert(type(aopType) == "string", string.format("the parameter of aopType:%s is not string", tostring(aopType)))
	assert(type(callback) == "function", string.format("the parameter of callback:%s is not function", tostring(callback)))
	
	local object = _getAopObjectByTarget(target, field)
	if not object then
		return
	end
	return object:removeAspect(aopType, callback, removeall)
end

function M.removeAspectByFile(file, field, aopType, callback, removeall)
	assert(type(file) == "string", string.format("the parameter of file:%s is not string", tostring(file)))
	local target = require(file)
	return M.removeAspectByTarget(target, field, aopType, callback, removeall)
end

return M 