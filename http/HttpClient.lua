local CURRENT_MODULE_NAME = ...

local HttpRequestType = import(".HttpRequestType",CURRENT_MODULE_NAME)
local HttpUtil = import(".HttpUtil",CURRENT_MODULE_NAME)

local M = class("HttpClient")


-- 通过request发送http请求
-- @param #CocosHttpRequest requestObject
function M:start(requestObject) end

-- 通过request暂停http请求
-- @param #CocosHttpRequest requestObject
function M:stop(requestObject) end

-- 统计http的访问
function M:_statist(requestObject, responseCode, duration) end

local function _appendGetRequestArguments(url, args)
	if args == nil then
		return url
	end
	local result = string.find(url, "%?")
	if result == nil then
		url = url .. "?";
	else
		url = url .. "&";
	end
	local values = {}
	for k, v in pairs(args) do
		table.insert(values, string.format("%s=%s", HttpUtil.encodeURI(tostring(k)), HttpUtil.encodeURI(tostring(v))))
	end
	return url .. table.concat(values, '&')
end

local function _parseRequestArguments(url, args, isCustom)
	if args == nil then
		return url
	end
	local returnData = args
	if not isCustom then
		local values = {}
		for k, v in pairs(args) do
			table.insert(values, string.format("%s=%s", k, v))
		end
		returnData = table.concat(values, '&')
	end
	return url, returnData
end

local kRequestTypeHandler = {
	[HttpRequestType.Get] = _appendGetRequestArguments,
	[HttpRequestType.Post] = _parseRequestArguments,
}

function M:_getUrlAndData(requestObject)
	local handler = kRequestTypeHandler[requestObject:getRequestType()]
	assert(handler ~= nil, string.format("there is not support request type:%s", requestObject:getRequestType()))
	
	return handler(requestObject:getCurrentUrl(), requestObject:getArguments(), requestObject.getIsCustom and requestObject:getIsCustom())
end

return M 