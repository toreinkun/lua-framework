--[[
    MIT License

    Copyright (c) 2018 HIBIKI

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]
local assert = assert
local string = string
local type = type
local select = select

local M = setglobal("lang", {})

local _langCfgs = {}
M.init = function(path)
    _langCfgs = table.load(path)
end

--[[
	@desc:get the language string for key 
	@example:
		10001 = "这是测试%d的%s"
		lang("10001", 1, "aaa") -- 这是测试1的aaa
    --@_:[#table]
	--@key:[#string]
	--@args:[#va_list]
    @return:[#string]
]]
local function _lang(_, key, ...)
    assert(
        type(key) == "string" or type(key) == "number",
        string.format("the parameter of key:%s is not string or number", tostring(key))
    )
    local value = _langCfgs[key]
    if not value then
        return ""
    end
    if select("#", ...) > 0 then
        value = string.format(value, ...)
    end
    return value
end

setmetatable(M, {__call = _lang})

return M
