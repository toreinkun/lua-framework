--[[
    MIT License

    GitHub: https://github.com/toreinkun/lua-framework

    Author: HIBIKI <toreinkun@gmail.com>

    Copyright (c) 2018-Now HIBIKI <toreinkun@gmail.com>

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
local type = type
local string = string
local table = table
local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local rawget = rawget
local tolua = tolua

local setmetatableindex_
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then
            setmetatable(t, index)
        elseif not mt.__index then
            mt.__index = index
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
setmetatableindex = setmetatableindex_

function class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function", string.format('class() - create class "%s" with invalid super class type "%s"', classname, superType))

        if superType == "function" then
            assert(cls.__create == nil, string.format('class() - create class "%s" with more than one creating function', classname))
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil, string.format('class() - create class "%s" with more than one creating function or native class', classname))
                cls.__create = function()
                    return super:create()
                end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format('class() - create class "%s" with invalid super type', classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(
            cls,
            {
                __index = function(_, key)
                    local supers = cls.__supers
                    for i = 1, #supers do
                        local super = supers[i]
                        if super[key] then
                            return super[key]
                        end
                    end
                end
            }
        )
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function()
        end
    end
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end

    --[[
    此方法用于构造集成于C++对象的lua对象，并执行相应的构造函数.
    ------------------------------------------------------------------------------------------------------------------------
    每个C++对象需要存贮自己的成员变量的值，这个值不能够存贮在元表里(因为元表是类共用的)，所以每个对象要用一个私有的表来存贮，
    这个表在tolua里叫做peer表。元表的__index指向了一个C函数，当在Lua中要访问一个C++对象的成员变量(准确的说是一个域)时，
    会调用这个C函数，在这个C函数中，会查找各个关联表来取得要访问的域，这其中就包括peer表的查询。
    --]]
    cls.extend = function(instance, ...)
        -- 先继承C++对象
        setmetatableindex(instance, cls)
        if not instance.class then
            instance.class = cls
        end
        instance:ctor(...)
        return instance
    end

    return cls
end

local iskindof_
iskindof_ = function(cls, name)
    local __index = rawget(cls, "__index")
    if type(__index) == "table" and rawget(__index, "__cname") == name then
        return true
    end

    if rawget(cls, "__cname") == name then
        return true
    end
    local __supers = rawget(cls, "__supers")
    if not __supers then
        return false
    end
    for _, super in ipairs(__supers) do
        if iskindof_(super, name) then
            return true
        end
    end
    return false
end

function iskindof(obj, classname)
    local t = type(obj)
    if t ~= "table" and t ~= "userdata" then
        return false
    end

    local mt
    if t == "userdata" then
        if tolua.iskindof(obj, classname) then
            return true
        end
        mt = tolua.getpeer(obj)
    else
        mt = getmetatable(obj)
    end
    if mt then
        return iskindof_(mt, classname)
    end
    return false
end
