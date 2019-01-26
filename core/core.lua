local debug = debug
local table = table
local require = require
local string = string
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable
local rawset = rawset

function traceback(baseLevel)
    local ret = { }
    local level = baseLevel or 2
    local stackBegan = false
    while true do
        local info = debug.getinfo(level, "Sln")
        if not info then
            break
        end
        if info.what == "C" then
            table.insert(ret, string.format("%i\tC function %s",(level - baseLevel + 1), info.name))
            stackBegan = true
        else
            if info.source ~= "=(tail call)" or stackBegan then
                table.insert(ret, string.format("%i\t[string \"%s\"]:%d in function %s",(level - baseLevel + 1), info.source, info.currentline, info.name or info.what))
                stackBegan = true
            end
        end
        level = level + 1
    end
    return table.concat(ret, "\n")
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        -- 点的asii.
        if string.byte(moduleName, offset) ~= 46 then
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n, v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function clone(object)
    local lookup_table = { }
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = { }
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

local _g = _G
function setglobal(name, value)
    rawset(_g, name, value)
    return value
end

--TODO
--[[
function module(name)
    local M = _g[name]
    if not M then 
        M = {}
        local ret, G = pcall(getfenv, 2)
        G = ret and G or _g
        setmetatable(M, { __index = G })
        setglobal(name, M)
    end 
    setfenv(2, M)
    return M
end
--]]

--TODO
--[[
setmetatable(_g, {
    __newindex = function(_, name, value)
        error(string.format("USE \" setglobal(%s, value) \" INSTEAD OF SET GLOBAL VARIABLE", tostring(name)), 0)
    end
} )
]]

local CURRENT_MODULE_NAME = ...
require(string.match(CURRENT_MODULE_NAME, "(.+[.])[^.]+$") .. "string")

import(".io", CURRENT_MODULE_NAME)
import(".table", CURRENT_MODULE_NAME)
import(".oop", CURRENT_MODULE_NAME)
import(".dump", CURRENT_MODULE_NAME)
import(".math", CURRENT_MODULE_NAME)
import(".vec2", CURRENT_MODULE_NAME)
import(".vec3", CURRENT_MODULE_NAME)
import(".vec4", CURRENT_MODULE_NAME)
import(".c3b", CURRENT_MODULE_NAME)
import(".c4b", CURRENT_MODULE_NAME)
import(".c4f", CURRENT_MODULE_NAME)
import(".size", CURRENT_MODULE_NAME)
import(".rect", CURRENT_MODULE_NAME)
import(".lang", CURRENT_MODULE_NAME)
import(".uid", CURRENT_MODULE_NAME)
