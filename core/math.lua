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

math.FLT_EPSILON = 1.192092896e-7

math.FLOAT_SMALL = 1.0e-37
math.TOLERANCE = 2e-37
math.PIOVER2 = 1.57079632679489661923
math.EPSILON = 0.000001

-- 初始化一个新的随机种子
function math.newrandomseed()
    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()
    math.random()
end

local _round_pow_10 = {10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000}
local _round_half_1 = 0.50000001
--[[
    @desc:rounds off to giving decimal places
    --@value:[#number]
	--@reserve:[#int]
    @return:[#number]
]]
function math.round(value, reserve)
    reserve = reserve or 0

    if reserve <= 0 then
        value = math.floor(value + _round_half_1)
    else
        local p = _round_pow_10[reserve] or math.pow(10, reserve)
        value = math.floor(value * p + _round_half_1) / p
    end

    return value
end

local _pi_div_180 = math.pi / 180
local _180_div_pi = 1 / _pi_div_180
--[[
    @desc:convert angle to radian
    --@angle:[#number]
    @return:[#number]
]]
function math.angle2radian(angle)
    return angle * _pi_div_180
end

--[[
    @desc:convert radian to angle
    --@radian:[#number]
    @return:[#number]
]]
function math.radian2angle(radian)
    return radian * _180_div_pi
end

--[[
    @desc:clamp value to the range [min, max]
    --@value:[#number]
	--@min_inclusive:[#number]
	--@max_inclusive:[#number]
    @return:[#number]
]]
function math.clamp(value, min_inclusive, max_inclusive)
    local temp = 0
    if min_inclusive > max_inclusive then
        temp = min_inclusive
        min_inclusive = max_inclusive
        max_inclusive = temp
    end

    if value < min_inclusive then
        return min_inclusive
    elseif value < max_inclusive then
        return value
    else
        return max_inclusive
    end
end

function math.formatnumberthousands(value)
end

--[[
    @desc:return (value >= threshold) ? 1 : 0
    --@threshold:[#number]
	--@value:[#number]
    @return:[#number]
]]
function math.step(threshold, value)
    return value >= threshold and 1 or 0
end

--[[
    @desc:return x + s(y - x)
    --@x:[#number]
	--@y:[#number]
	--@s:[#number] 
    @return:[#number]
]]
function math.lerp(x, y, s)
    return x + s * (y - x)
end

--[[
    @desc:clamp value to the range [0, 1]
    --@value:[#number]
    @return:
]]
function math.saturate(value)
    return value < 0 and 0 or (value > 1 and 1 or value)
end

--[[
    @desc:return a smooth Hermite interpolation between 0 and 1
    --@a:[#number]
	--@b:[#number]
	--@x:[#number]
    @return:[#number]
]]
function math.smoothstep(a, b, x)
    local t = math.saturate((x - a) / (b - a))
    return t * t * (3.0 - (2.0 * t))
end
