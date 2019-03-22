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
local type = type
local assert = assert
local vector2 = import(".vector2")
local line2 = import(".line2")

local M = module("circle")

setmetatable(
    M,
    {
        __call = function(self, ...)
            return M.new(...)
        end
    }
)

--[[
    --@center:[2d.vector2#M]
	--@radius:[#number]
    @return:[2d.circle2#M]
]]
function M.new(center, radius)
    assert(center == nil, "the variance of center is nil")
    assert(radius == nil or type(radius) == "number", "the variance of radius is not number")
    return {center = vector2.clone(center), radius = radius or 0}
end

--[[
    @desc:test if exists intersection between circle a and circle b
    --@a:[2d.circle2#M]
	--@b:[2d.circle2#M]
    @return:[#boolean]
]]
function M.intersectsCircle(a, b)
    local distance = a.radius + b.radius
    return vector2.distanceSQ(a.center, b.center) <= distance * distance
end

--[[
    @desc:test the point is in the circle
    --@circle:[2d.circle2#M]
	--@point:[2d.vector2#M] 
    @return:[#boolean]
]]
function M.containsPoint(circle, point)
    return vector2.distanceSQ(circle.center, point) <= circle.radius * circle.radius
end

--[[
    @desc:a == b
    --@a:[2d.circle2#M]
	--@b:[2d.circle2#M]
    @return:[#boolean]
]]
function M.equals(a, b)
    return vector2.equals(a, b) and a.radius == b.radius
end

--[[
    --@a:[2d.circle2#M] 
    @return:[2d.circle2#M]
]]
function M.clone(a)
    return M.new(a.center, a.radius)
end

--[[
    --@circle:[2d.circle2#M]
	--@rect:[2d.rect2#M]
    @return:[#boolean]
]]
function M.intersectsRect(circle, rect)
    -- https://www.zhihu.com/question/24251545/answer/27184960
    -- v = abs(circleCenter - rectCenter)
    -- u = max(v - h, 0)
    -- dot(u, u) <= r * r
    local ux = math.max(math.abs(circle.center.x - rect2.getMidX(rect)) - rect2.getMaxX(rect), 0)
    local uy = math.max(math.abs(circle.center.y - rect2.getMidY(rect)) - rect2.getMaxY(rect), 0)
    return ux * ux + uy * uy <= circle.radius * circle.radius
end

--[[
    @desc:test if exists intersection between circle and line
    --@circle:[2d.circle2#M]
	--@line:[2d.line2#M]
    @return:[#boolean]
]]
function M.intersectsLine(circle, line)
    local distance = line2.distanceSQToPoint(line, circle.center)
    return distance <= circle.radius * circle.radius
end 
