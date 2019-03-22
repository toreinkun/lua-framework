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
local vector2 = import(".vector2")

local M = module("line2")

--@RefType [#number]
M.kMinType = 0
--@RefType [#number]
M.kLineType = 0
--@RefType [#number]
M.kRayType = 1
--@RefType [#number]
M.kSegmentType = 2
--@RefType [#number]
M.kMaxType = 2

setmetatable(
    M,
    {
        __call = function(self, ...)
            return M.new(...)
        end
    }
)

--[[
    --@startPoint:[2d.vector2#M]
    --@endPoint:[2d.vector2#M]
    --@lineType:[#number]
    @return:[2d.line2#M]
]]
function M.new(startPoint, endPoint, lineType)
    assert(startPoint ~= nil, "the variable of startPoint is nil")
    assert(endPoint ~= nil, "the variable of endPoint is nil")
    assert(lineType == nil or type(lineType) == "number", string.format("the variable of lineType:%s is not number", tostring(lineType)))
    assert(
        not vector2.equals(startPoint, endPoint),
        string.format("startPoint(%s,%s) can't equal to endPoint(%s,%s)", tostring(startPoint.x), tostring(startPoint.y), tostring(endPoint.x), tostring(endPoint.y))
    )
    lineType = lineType or M.kLineType
    assert(lineType >= M.kMinType and lineType <= M.kMaxType, string.format("the variable of lineType:%s is out of range", tostring(lineType)))
    return {startPoint = vector2.clone(startPoint), endPoint = vector2.clone(endPoint), vector = vector2.sub(endPoint, startPoint), lineType = lineType}
end

--[[
    --@a:[2d.line2#M]
    @return:
]]
function M.length(a)
    return vector2.distance(a.startPoint, a.endPoint)
end

--[[
    --@a:[2d.line2#M]
    @return:[2d.vector2#M]
]]
function M.vector(a)
    return vector2.sub(a.endPoint, a.startPoint)
end

--[[
    @desc:a == b
    --@a:[2d.line2#M]
	--@b:[2d.line2#M]
    @return:[#boolean]
]]
function M.equals(a, b)
    return vector2.equals(a.startPoint, b.startPoint) and vector2.equals(a.endPoint, b.endPoint) and a.lineType == b.lineType
end

--[[
    --@a:[2d.line2#M]
	--@b:[2d.line2#M] 
    @return:[#number]
]]
function M.dot(a, b)
    return a.vector.x * b.vector.x + a.vector.y * b.vector.y
end

--[[
    --@a:[2d.line2#M]
	--@b:[2d.line2#M] 
    @return:[#number]
]]
function M.cross(a, b)
    return a.vector.x * b.vector.y - a.vector.y * b.vector.x
end

--[[
    @desc:use vector method to get intersect point between line ab and line cd, the result is factor
    --@a:[2d.line2#M]
    --@b:[2d.line2#M]
    @return:[#boolean]
    @return:[#number]
    @return:[#number]
]]
local function _getLineIntersect(a, b)
    -- a0 = a1 + s * (a1a2), a0 is a point on line a1a2
    -- b0 = b1 + t * (b1b2), b0 is a point on line b1b2
    -- a1 + s * (a1a2) = b1 + t * (b1b2)
    -- a1 X b1b2 + s * (a1a2 X b1b2) = b1 X b1b2 + t * (b1b2 X b1b2)
    -- s = (b1 - a1) X b1b2 / (a1a2 X b1b2) = (a1b1 X b1b2) / (a1a2 X b1b2)
    -- a1 X a1a2 + s * (a1a2 X a1a2) = b1 X a1a2 + t * (b1b2 X a1a2)
    -- t = (a1 - b1) X a1a2 / (b1b2 X a1a2) = -b1a1 X a1a2 / -(b1b2 X a1a2) = (a1b1 X a1a2) / (a1a2 X b1b2)

    local a1b1x = b.startPoint.x - a.startPoint.x
    local a1b1y = b.startPoint.y - a.startPoint.y

    local denom = M.cross(b, a)
    local s = b.vector.x * a1b1y - b.vector.y * a1b1x
    local t = a.vector.x * a1b1y - a.vector.y * a1b1x

    if denom == 0 then
        if s ~= 0 and t ~= 0 then
            -- parallel
            return false
        end
        -- collinear
        if a.lineType == M.kLineType or b.lineType == M.kLineType then
            return 1, 0, nil
        end
        if a.lineType == M.kRayType then
            -- a1a2 · a1b1 >= 0, b1 is on ray a1a2
            if a.vector.x * a1b1x + a.vector.y * a1b1y >= 0 then
                return 1, nil, 0
            end
            if b.lineType == M.kRayType then
                -- b1b2 · b1a1 >= 0, a1 is on ray b1b2
                if b.vector.x * -a1b1x + b.vector.y * -a1b1y >= 0 then
                    return 1, 0, nil
                end
            else
                -- a1a2 · a1b2 >= 0, b2 is on ray a1a2
                if a.vector.x * (b.endPoint.x - a.startPoint.x) + a.vector.y * (b.endPoint.y - a.startPoint.y) >= 0 then
                    return 1, nil, 1
                end
            end
        else
            -- a1b1 · a2b1 <= 0, b1 is on segment a1a2
            if a1b1x * (b.startPoint.x - a.endPoint.x) + a1b1y * (b.startPoint.y - a.endPoint.y) <= 0 then
                return 1, nil, 0
            end
            if b.lineType == M.kRayType then
                -- b1b2 · b1a1 >=0, a1 is on ray b1b2
                if b.vector.x * -a1b1x + b.vector.y * -a1b1y >= 0 then
                    return 1, 0, nil
                end
            else
                -- a1b2 · a2b2 <= 0, b2 is on segment a1a2
                if (b.endPoint.x - a.startPoint.x) * (b.endPoint.x - a.endPoint.x) + (b.endPoint.y - a.startPoint.y) * (b.endPoint.y - a.endPoint.y) <= 0 then
                    return 1, nil, 1
                end
            end
        end
        return false
    end

    if s < 0 and a.lineType ~= M.kLineType then
        return false
    end
    if s > denom and a.lineType == M.kSegmentType then
        return false
    end
    if t < 0 and b.lineType ~= M.kLineType then
        return false
    end
    if t > denom and b.lineType == M.kSegmentType then
        return false
    end

    return denom, s, t
end

--[[
    @desc:test if point on line
    --@line:[2d.line2#M]
	--@point:[2d.vector2#M]
    @return:[#boolean]
]]
function M.containsPoint(line, point)
    local a1px = p.x - line.startPoint.x
    local a1py = p.y - line.startPoint.y
    -- a1a2 X a1p = 0, p is on line a1a1
    if line.vector.x * a1py - line.vector.y * a1px ~= 0 then
        return false
    end
    if line.lineType == M.kLineType then
        return true
    elseif line.lineType == M.kRayType then
        -- a1a2 · a1p >= 0, p is on ray a1a2
        return ray.vector.x * a1px + ray.vector.y * a1py >= 0
    else
        -- pa1 · pa2 <= 0, p is on segment a1a2
        return (line.startPoint.x - point.x) * (line.endPoint.x - point.x) + (line.startPoint.y - point.y) * (line.endPoint.y - point.y) <= 0
    end
end

--[[
    @desc:test if exists intersection between line a and line b
    --@a:[2d.line2#M]
	--@b:[2d.line2#M]
    @return:[#boolean]
]]
function M.intersectsLine(a, b)
    local ret = _getLineIntersect(a, b)
    return ret ~= false
end

--[[
    @desc:get intersection point between line a and line b. return nil if there is not a intersection.
    --@a:[2d.line2#M]
	--@b:[2d.line2#M]
    @return:[#boolean]
]]
function M.intersection(a, b)
    local ret, s, t = _getLineIntersect(a, b)

    if not ret then
        return nil
    end

    if s then
        s = s / denom
        return vector2.new(a.startPoint.x + s * a.vector.x, a.startPoint.y + s * a.vector.y)
    elseif t then
        t = t / denom
        return vector2.new(b.startPoint.x + t * b.vector.x, a.startPoint.y + t * b.vector.y)
    end
end

--[[
    @desc:get the distance from point to line
    --@line:[2d.line2#M]
	--@point:[2d.vector2#M]
    @return:[#number]
]]
function M.distanceToPoint(line, point)
    return math.sqrt(M.distanceSQToPoint(line, point))
end

--[[
    @desc:get the distance square from point to line
    --@line:[2d.line2#M]
	--@point:[2d.vector2#M]
    @return:[#number]
]]
function M.distanceSQToPoint(line, point)
    local a1px = point.x - line.startPoint.x
    local a1py = point.y - line.startPoint.y
    if line.lineType == M.kRayType or line.lineType == M.kSegmentType then
        -- if the angle between a1p and a1a2 is larger than 90, the distance is |a1p|
        if a1px * line.vector.x + a1py * line.vector.y <= 0 then
            return a1px * a1px + a1py * a1py
        end
        if line.lineType == M.kSegmentType then
            -- if the angle between a2p and a2a1 is larger than 90, the distance is |a2p|
            local a2px = point.x - line.endPoint.x
            local a2py = point.y - line.endPoint.y
            if a2px * -line.vector.x + a2py * -line.vector.y <= 0 then
                return a2px * a2px + a2py * a2py
            end
        end
    end
    -- a1p X a1a2 = 2 * Spa1a2
    -- |a1a2| * h / 2 = Spa1a2
    -- h = a1p X a1a2 / |a1a2|
    local S = (a1px * a.vector.y - a1py * a.vector.x)
    return S * S / vector2.lengthSQ(a.vector)
end

return M
