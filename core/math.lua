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

local _roundPow10 = { 10, 100, 1000, 10000, 100000 }
-- 四舍五入
-- @param #number value
-- @param #int reserve
-- @return #int
function math.round(value, reserve)
    reserve = reserve or 0

    if reserve <= 0 then
        value = math.floor(value + 0.50000001)
    else
        local p = _roundPow10[reserve] or math.pow(10, reserve)
        value = math.floor(value * p + 0.50000001) / p
    end

    return value
end

local _pi_div_180 = math.pi / 180
local _180_div_pi = 1 / _pi_div_180
-- 角度转弧度
-- @param radian #angle
-- @return #number
function math.angle2radian(angle)
    return angle * _pi_div_180
end

-- 弧度转角度
-- @param radian #number
-- @return #number
function math.radian2angle(radian)
    return radian * _180_div_pi
end

-- 计算夹紧到由第二个和第三个指定的参数所定义的范围内的第一个指定的参数的值
-- @param value #number
-- @param min_inclusive #number
-- @param max_inclusive #number
-- @return #number
function math.clampf(value, min_inclusive, max_inclusive)
    -- body
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
