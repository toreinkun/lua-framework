local CURRENT_MODULE_NAME = ...

local type = type
local assert = assert
local string = string

local HttpRequestType = import(".HttpRequestType",CURRENT_MODULE_NAME)

local M = class("HttpRequest")

local kDefaultTimeout = 15

M._curUrlIndex = 0
M._urls = nil
M._args = nil
M._requestType = nil

M._callback = nil
M._obj = nil

M._headers = nil
M._timeout = 0
M._isCustom= false

function M:ctor(urls, args, callback, obj)
	-- 检查url是否都是string
	if type(urls) == "string" then
		urls = {urls}
    elseif type(urls) ~= "table" then
        assert(type(urls == "table"), string.format("the parameter of urls:%s is not table", tostring(urls)))
		return
	else
        assert(urls[1] ~= nil, "the parameter of url is empty table")
		for _, url in ipairs(urls) do
            assert(type(url == "string"), string.format("the parameter of url:%s is not string", tostring(url)))
		end
	end
	-- 检查args是否都是string,这里不一定非得string
	if args ~= nil then
        assert(type(args == "table"), string.format("the parameter of args:%s is not table", tostring(args)))
  --       for name, value in pairs(args) do
  --           assert(type(name == "string"), string.format("the parameter of name:%s is not string", tostring(name)))
  --           assert(type(value == "string"), string.format("the parameter of value:%s is not string", tostring(value)))
		-- end
	end
	-- 检查callback是否function
    assert(callback == nil or type(callback) == "function", string.format("the parameter of callback:%s is not function", tostring(callback)))
        
	self._curUrlIndex = 1
	self._urls = urls
	self._args = args
	self._callback = callback
	
	self._timeout = kDefaultTimeout
	self._requestType = HttpRequestType.Get
end


function M:setIsCustom(isCustom)
	self._isCustom = isCustom
end

function M:getIsCustom()
	return self._isCustom
end

 

function M:setRequestType(requestType)
	assert(type(requestType == "string"), string.format("the parameter of requestType:%s is not string", tostring(requestType)))
	self._requestType = requestType
end

function M:getRequestType()
	return self._requestType
end

function M:getCurrentUrl()
	return self._urls[self._curUrlIndex]
end

function M:addUrlIndex()
	self._curUrlIndex = self._curUrlIndex + 1
end

function M:isLastUrl()
	return self._urls[self._curUrlIndex + 1] == nil
end

function M:getArguments()
	return self._args
end

function M:setTimeout(timeout)
	assert(type(timeout == "number"), string.format("the parameter of timeout:%s is not number", tostring(timeout)))
	self._timeout = timeout
end

function M:getTimeout()
	return self._timeout
end

function M:setHader(name, value)
	assert(type(name == "string"), string.format("the parameter of name:%s is not string", tostring(name)))
	assert(type(name == "value"), string.format("the parameter of value:%s is not string", tostring(value)))
	if not self._headers then
		self._headers = {}
	end
	self._headers[name] = value
end

function M:removeHeader(name)
	assert(type(name == "string"), string.format("the parameter of name:%s is not string", tostring(name)))
	if not self._headers then
		return
	end
	self._headers[name] = value
end

function M:getHeaders()
	return self._headers
end

function M:respond(response)
	if self._obj then
		self._callback(self._obj, response)
	else
		self._callback(response)
	end
end

return M 