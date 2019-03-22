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
local math = math
local vector2 = import(".vector2")
local size2 = import(".size2")

local M = module("rect2")

setmetatable(
    M,
    {
        __call = function(self, ...)
            return M.new(...)
        end
    }
)

--[[
    --@point:[2d.vector2#M]
	--@size:[2d.size2#M]
    @return:[2d.rect2#M]
]]
function M.new(point, size)
    return {point = vector2.clone(point), size = size2.clone(size)}
end

--[[
    @desc:a == b
    --@a:[2d.rect2#M]
	--@b:[2d.rect2#M]
    @return:[#boolean]
]]
function M.equals(a, b)
    return vector2.equals(a.point, b.point) and size2.equals(a.size, b.size)
end

--[[
    --@a:[2d.rect2#M] 
    @return:[2d.rect2#M]
]]
function M.clone(a)
    return M.new(a.point, a.size)
end

--[[
    @desc:get x position of top right corner
    --@a:[2d.rect2#M]
    @return:[#number]
]]
function M.getMaxX(a)
    return a.point.x + a.size.width
end

--[[
    @desc:get x position of middle center
    --@a:[2d.rect2#M]
    @return:[#number]
]]
function M.getMidX(a)
    return a.point.x + a.size.width / 2.0
end

--[[
    @desc:get x position of left bottom corner
    --@a:[2d.rect2#M]
    @return:[#number]
]]
function M.getMinX(a)
    return a.point.x
end

--[[
    @desc:get y position of top right corner
    --@a:[2d.rect2#M]
    @return:[#number]
]]
function M.getMaxY(a)
    return a.point.y + a.size.height
end

--[[
    @desc:get y position of middle center
    --@a:[2d.rect2#M]
    @return:[#number]
]]
function M.getMidY(a)
    return a.point.y + a.size.height / 2.0
end

--[[
    @desc:get y position of left bottom corner
    --@a:[2d.rect2#M]
    @return:[#number]
]]
function M.getMinY(a)
    return a.point.y
end

--[[
    @desc:test the point is in the rect
    --@rect:[2d.rect2#M]
	--@point:[2d.vector2#M]
    @return:[#boolean]
]]
function M.containsPoint(rect, point)
    return (point.x >= rect.point.x) and (point.x <= rect.x + rect.width) and (point.y >= rect.y) and (point.y <= rect.y + rect.height)
end

--[[
    @desc:test whether two rect intersect
    --@a:[#rect]
	--@b:[#rect] 
    @return:[#boolean]
]]
function M.intersectsRect(a, b)
    return not (a.x > b.x + b.width or a.x + a.width < b.x or a.y > b.y + b.height or a.y + a.height < b.y)
end

--[[
    @desc:c = a ∪ b
    --@a:[#rect]
	--@b:[#rect]
    @return:[#rect]
]]
function M.union(a, b)
    local c = M.new(0, 0, 0, 0)
    c.x = math.min(a.x, b.x)
    c.y = math.min(a.y, b.y)
    c.width = math.max(a.x + a.width, b.x + b.width) - c.x
    c.height = math.max(a.y + a.height, b.y + b.height) - c.y
    return c
end

--[[
    @desc:c = a ∩ b
    --@a:[#rect]
	--@b:[#rect]
    @return:[#rect]
]]
function M.intersection(a, b)
    local x = math.max(a.x, b.x)
    local y = math.max(a.y, b.y)
    local width = math.min(a.x + a.width, b.x + b.width) - x
    local height = math.min(a.y + a.height, b.y + b.height) - y
    if width < 0 or height < 0 then
        return nil
    end
    return M.new(x, y, width, height)
end

--[[
    @desc:b = a ↺ 90°
    --@a:[#rect] 
    @return:[#rect]
]]
function M.perp(a)
    local b = M.new(0, 0, 0, 0)
    b.x = a.x + a.width / 2.0 - a.height / 2.0
    b.y = a.y - a.width / 2.0 + a.height / 2.0
    b.width = a.height
    b.height = a.width
    return b
end

--[[
    @desc:b = a * factor
    --@a:[#rect]
	--@factor:[#number]
    @return:[#rect]
]]
function M.scale(a, factor)
    local b = M.new(0, 0, 0, 0)
    b.x = a.x + (factor - 1) * a.width / 2.0
    b.y = a.y + (factor - 1) * a.height / 2.0
    b.width = a.width * factor
    b.height = a.height * factor
    return b
end

return M
