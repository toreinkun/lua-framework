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

local M = module("vector2")

setmetatable(
    M,
    {
        __call = function(self, ...)
            return M.new(...)
        end
    }
)

--[[
    --@x:[#number]
	--@y:[#number]
    @return:[2d.vector2#M]
]]
function M.new(x, y)
    assert(x == nil or type(x) == "number", "the variance of x is not number")
    assert(y == nil or type(y) == "number", "the variance of y is not number")
    return {x = x or 0, y = y or 0}
end

--[[
    @desc:C = A + B
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.add(a, b)
    return M.new(a.x + b.x, a.y + b.y)
end

--[[
    @desc:A = A + B
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M:addToSelf(a, b)
    a.x = a.x + b.x
    a.y = a.y + b.y
    return a
end

--[[
    @desc:C = A - B
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.sub(a, b)
    return M.new(a.x - b.x, a.y - b.y)
end

--[[
    @desc:A = A - B
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.subToSelf(a, b)
    a.x = a.x - b.x
    a.y = a.y - b.y
    return a
end

--[[
    @desc:B = A * factor
    --@a:[2d.vector2#M]
	--@factor:[#number]
    @return:[2d.vector2#M]
]]
function M.mul(a, factor)
    assert(type(factor) == "number", "the variance of factor is not number")
    return M.new(a.x * factor, a.y * factor)
end

--[[
    @desc:A = A * factor
    --@pt:[2d.vector2#M]
	--@factor:[#number]
    @return:[2d.vector2#M]
]]
function M.mulToSelf(a, factor)
    assert(type(factor) == "number", "the variance of factor is not number")
    a.x = a.x * factor
    a.y = a.y * factor
    return a
end

--[[
    @desc:C = (A + B)/2
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.midpoint(a, b)
    return M.new((a.x + b.x) / 2.0, (a.y + b.y) / 2.0)
end

--[[
    @desc:1.|OA|
          2.|A|
    --@a:[2d.vector2#M] 
    @return:[#float]
]]
function M.length(a)
    return math.sqrt(a.x * a.x + a.y * a.y)
end

--[[
    @desc:B = A / |A|
    --@a:[2d.vector2#M]  
    @return:[2d.vector2#M] 
]]
function M.normalize(a)
    local n = M.dot(a, a)
    if n == 1 then
        return M.new(a.x, a.y)
    end
    n = math.sqrt(n)
    if n < math.TOLERANCE then
        return M.new(a.x, a.y)
    end
    return M.mul(a, 1 / n)
end

--[[
    @desc:A = A / |A|
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.normalizeToSelf(a)
    local n = M.dot(a, a)
    if n == 1 then
        return a
    end
    n = math.sqrt(n)
    if n < math.TOLERANCE then
        return a
    end
    return M.mulSelf(a, 1 / n)
end

--[[
    @desc:1.A X B
          2.|A| * |B| * sinθ
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[#float]
]]
function M.cross(a, b)
    return a.x * b.y - a.y * b.x
end

--[[
    @desc:1.A · B
          2.|A| * |B| * cosθ, θ is the angle between a and b
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[#float]
]]
function M.dot(a, b)
    return a.x * b.x + a.y * b.y
end

--[[
    @desc:get a normalized vector that is radian from the x axis
    --@a:[#float] radian
    @return:[2d.vector2#M]
]]
function M.forAngle(a)
    return M.new(math.cos(a), math.sin(a))
end

--[[
    @desc:get the angle between vec and x axis
    --@a:[2d.vector2#M]
    @return:[#float] radian
]]
function M.toAngle(a)
    return math.atan2(a.y, a.x)
end

--[[
    @desc:get the rotate angle from a and b
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[#float] radian
]]
function M.angle(a, b)
    local a2 = M.normalize(a)
    local b2 = M.normalize(b)
    local angle = math.atan2(M.cross(a2, b2), M.dot(a2, b2))
    if math.abs(angle) < math.FLT_EPSILON then
        return 0
    end

    return angle
end

--[[
    @desc:1.|AB|
          2.|A-B|
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[#float]
]]
function M.distance(a, b)
    local x = a.x - b.x
    local y = a.y - b.y
    return math.sqrt(x * x + y * y)
end

--[[
    @desc:B = A ↺ 90°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.perp(a)
    return M.new(-a.y, a.x)
end

--[[
    @desc:A = A ↺ 90°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.perpToSelf(a)
    local x = a.x
    a.x = -a.y
    a.y = x
    return a
end

--[[
    @desc:B = A ↺ -90°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rperp(a)
    return M.new(a.y, -a.x)
end

--[[
    @desc:A = A ↺ -90°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rperpToSelf(a)
    local x = a.x
    a.x = a.y
    a.y = -x
    return a
end

--[[
    @desc:B = -A
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.negate(a)
    return M.new(-a.x, -a.y)
end

--[[
    @desc:A = -A
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.negateToSelf(a)
    a.x = -a.x
    a.y = -a.y
    return a
end

--[[
    @desc:C = Projection of vector A on vector B
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.project(a, b)
    -- C = |A| * cosθ * (B / |B|)
    -- C = |A| * (A·B/(|A|*|B|)) * (B / |B|)
    -- C = A·B / (|B|*|B|) * B
    -- C = A·B / B·B * B
    local rate = M.dot(a, b) / M.dot(b, b)
    return M.new(b.x * rate, b.y * rate)
end

--[[
    @desc:|C| = |Projection of vector A on vector B|
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[#number]
]]
function M.projectLength(a, b)
    -- |A| * cosθ
    -- |A| * A·B /(|A| * |B|)
    -- A·B/|B|
    return M.dot(a, M.normalize(b))
end

--[[
    @desc:1.C = A ↺ B, |C| = |A| * |B|
          2.C = A * B = (a + bi) * (c + di) = (a * c － b * d) + (b * c + a * d)i
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rotate(a, b)
    return M.new(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x)
end

--[[
    @desc:1.A = A ↺ B, |A| = |A| * |B|
          2.A = A * B = (a + bi) * (c + di) = (a * c － b * d) + (b * c + a * d)i
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rotateToSelf(a, b)
    local x = a.x
    a.x = a.x * b.x - a.y * b.y
    a.y = x * b.y + a.y * b.x
    return a
end

--[[
    @desc:B = A ↺ angle°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rotateByAngle(a, angle)
    assert(type(angle) == "number", "the variance of angle is not number")
    return M.new(a.x * math.cos(angle) - a.y * math.sin(angle), a.x * math.cos(angle) + a.y * math.sin(angle))
end

--[[
    @desc:A = A ↺ angle°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rotateByAngleToSelf(a, angle)
    assert(type(angle) == "number", "the variance of angle is not number")
    local x = a.x * math.cos(angle) - a.y * math.sin(angle)
    a.y = a.x * math.cos(angle) + a.y * math.sin(angle)
    a.x = x
    return a
end

--[[
    @desc:1.C = A ↺ -B, |C| = |A| * |B|
          2.C = A / B *|B| = (a + bi) / (c + di) * (c ^ 2 + d ^ 2) = (a * c + b * d) + (b * c - a * d)i
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.unrotate(a, b)
    return M.new(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y)
end

--[[
    @desc:1.A = A ↺ -B, |A| = |A| * |B|
          2.A = A / B *|B| = (a + bi) / (c + di) * (c ^ 2 + d ^ 2) = (a * c + b * d) + (b * c - a * d)i
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.unrotateToSelf(a, b)
    local x = a.x
    a.x = a.x * b.x + a.y * b.y
    a.y = a.y * b.x - x * b.y
    return a
end

--[[
    @desc:B = A ↺ -angle°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.unrotateByAngle(a, angle)
    assert(type(angle) == "number", "the variance of angle is not number")
    return M.new(a.x * math.cos(angle) + a.y * math.sin(angle), a.x * math.cos(angle) - a.y * math.sin(angle))
end

--[[
    @desc:A = A ↺ -angle°
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.unrotateByAngleToSelf(a, angle)
    assert(type(angle) == "number", "the variance of angle is not number")
    local x = a.x * math.cos(angle) + a.y * math.sin(angle)
    a.y = a.x * math.cos(angle) - a.y * math.sin(angle)
    a.x = x
    return a
end

--[[
    @desc:|A|^2
    --@a:[2d.vector2#M]
    @return:[#float]
]]
function M.lengthSQ(a)
    return M.dot(a, a)
end

--[[
    @desc:|A - B| ^ 2
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M] 
    @return:[#float]
]]
function M.distanceSQ(a, b)
    local x = a.x - b.x
    local y = a.y - b.y
    return x * x + y * y
end

--[[
    @desc:A == B
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M] 
    @return:[#boolean]
]]
function M.equals(a, b)
    return a.x == b.x and a.y == b.y
end

--[[
    @desc:A ≈ B
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
	--@variance:[#float]
    @return:[#boolean]
]]
function M.fuzzyEqual(a, b, variance)
    assert(variance == nil or type(variance) == "number", "the variance of input is not number")
    variance = variance or math.FLT_EPSILON
    if (a.x - variance <= b.x) and (b.x <= a.x + variance) and (a.y - variance <= b.y) and (b.y <= a.y + variance) then
        return true
    else
        return false
    end
end

--[[
    @desc:C = A + (B - A) * alpha
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
	--@alpha:[#float]
    @return:[2d.vector2#M]
]]
function M.lerp(a, b, alpha)
    assert(type(alpha) == "number", "the variance of alpha is not number")
    assert(alpha >= 0 and alpha <= 1, "the alpha must between 0 and 1")
    return M.new(a.x + (b.x - a.x) * alpha, a.y + (b.y - a.y) * alpha)
end

--[[
    @desc:A = A + (B - A) * alpha
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
	--@alpha:[#float]
    @return:[2d.vector2#M]
]]
function M.lerpToSelf(a, b, alpha)
    assert(type(alpha) == "number", "the variance of alpha is not number")
    assert(alpha >= 0 and alpha <= 1, "the alpha must between 0 and 1")
    a.x = a.x + (b.x - a.x) * alpha
    a.y = a.y + (b.y - a.y) * alpha
    return a
end

--[[
    @desc:D = A < B ? B : (A > C ? C : A)
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
	--@c:[2d.vector2#M] 
    @return:[2d.vector2#M]
]]
function M.clamp(a, b, c)
    return M.new(math.clamp(a.x, b.x, c.x), math.clamp(a.y, b.y, c.y))
end

--[[
    @desc:A = A < B ? B : (A > C ? C : A)
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
	--@c:[2d.vector2#M] 
    @return:[2d.vector2#M]
]]
function M.clampToSelf(a, b, c)
    a.x = math.clamp(a.x, b.x, c.x)
    a.y = math.clamp(a.y, b.y, c.y)
    return a
end

--[[
    @desc:C = A ↺ (b,angle°)
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
	--@angle:[#float]
    @return:[2d.vector2#M]
]]
function M.rotateCenterByAngle(a, b, angle)
    -- C = (A - B) ↺ angle° + B
    assert(type(angle) == "number", "the variance of angle is not number")
    return M.addToSelf(M.rotateByAngleToSelf(M.sub(a, b), angle), b)
end

--[[
    @desc:A = A ↺ (b,angle°)
    --@a:[2d.vector2#M]
	--@b:[2d.vector2#M]
	--@angle:[#float]
    @return:[2d.vector2#M]
]]
function M.rotateCenterByAngleToSelf(a, b, angle)
    -- A = (A - B) ↺ angle° + B
    assert(type(angle) == "number", "the variance of angle is not number")
    return M.addToSelf(M.rotateByAngleToSelf(M.subSelf(a, b), angle), b)
end

--[[
    @desc:C = A ↺ (b,180°)
    --@a:[2d.vector2#M]
    --@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.negateCenter(a, b)
    -- C = - (A - B) + B
    -- C = - A + 2 * B
    return M.new(-a.x + 2 * b.x, -a.y + 2 * b.y)
end

--[[
    @desc:A = A ↺ (b,180°)
    --@a:[2d.vector2#M]
    --@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.negateCenterToSelf(a, b)
    a.x = -a.x + 2 * b.x
    a.y = -a.y + 2 * b.y
    return a
end

--[[
    @desc:C = A ↺ (b,90°)
    --@a:[2d.vector2#M]
    --@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.perpCenter(a, b)
    -- C = (A - B) ↺ 90° + B
    -- (Cx, Cy) = (-(Ay - By) + Bx, (Ax - Bx) + By)
    return M.new(-a.y + b.y + b.x, a.x - b.x + b.y)
end

--[[
    @desc:A = A ↺ (b,90°)
    --@a:[2d.vector2#M]
    --@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.perpCenterToSelf(a, b)
    local x = a.x
    a.x = -a.y + b.y + b.x
    a.y = x - b.x + b.y
    return a
end

--[[
    @desc:B = A ↺ -90°
    --@a:[2d.vector2#M]
    --@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rperpCenter(a, b)
    -- C = (A - B) ↺ -90° + B
    -- (Cx, Cy) = (Ay - By + Bx, -(Ax - Bx) + By)
    return M.new(a.y - b.y + b.x, -a.x + b.x + b.y)
end

--[[
    @desc:A = A ↺ -90°
    --@a:[2d.vector2#M]
    --@b:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.rperpCenterToSelf(a, b)
    local x = a.x
    a.x = a.y - b.y + b.x
    a.y = -a.x + b.x + b.y
    return a
end

--[[
    --@a:[2d.vector2#M]
    @return:[2d.vector2#M]
]]
function M.clone(a)
    return M.new(a.x, a.y)
end

return M