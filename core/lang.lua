local _mapId2Model = {}

local M = setglobal("lang", {})
M.init = function(path)
	_mapId2Model = table.load(path)
end

--[[根据id获取字符串
@param id       对应配置文件中的id
@param ...      与对应字符串中相应的替换符号匹配
@return 

@example    
[10001] = "这是测试%d的%s"
lang(10001, 1, "aaa") -- 这是测试1的aaa
]]
setmetatable(M, {__call = function(_, key, ...)
	assert(type(key) == "string" or type(key) == "number", string.format("the parameter of key:%s is not string or number", tostring(key)))
	local value = _mapId2Model[key]
	if not value then
		return ""
	end
	if select("#", ...) > 0 then
		value = string.format(value, ...)
	end
	return value
end})

return M 