local math = math

-- Point
local M = setglobal("vec2", { })

setmetatable(M, {
    __call = function(self, ...)
        return M.new(...)
    end
} )

function M.new(_x, _y)
    if nil == _y then
        return { x = _x.x, y = _x.y }
    else
        return { x = _x, y = _y }
    end
end

function M.add(pt1, pt2)
    return { x = pt1.x + pt2.x, y = pt1.y + pt2.y }
end

function M:addSelf(pt1, pt2)
    pt1.x = pt1.x + pt2.x
    pt1.y = pt1.y + pt2.y
    return pt1
end

function M.sub(pt1, pt2)
    return { x = pt1.x - pt2.x, y = pt1.y - pt2.y }
end

function M.subSelf(pt1, pt2)
    pt1.x = pt1.x - pt2.x
    pt1.y = pt1.y - pt2.y
    return pt1
end

function M.mul(pt1, factor)
    return { x = pt1.x * factor, y = pt1.y * factor }
end

function M.mulSelf(pt1, factor)
    pt1.x = pt1.x * factor
    pt1.y = pt1.y * factor
    return pt1
end

-- 两点的中点
function M.midpoint(pt1, pt2)
    return { x = (pt1.x + pt2.x) / 2, y = (pt1.y + pt2.y) / 2 }
end

function M.forAngle(a)
    return { x = math.cos(a), y = math.sin(a) }
end

-- 长度
function M.getLength(pt)
    return math.sqrt(pt.x * pt.x + pt.y * pt.y)
end

-- 单位化
function M.normalize(pt)
    local n = M.dot(pt, pt)
    if n == 1 then
        return { x = pt.x, y = pt.y }
    end
    n = math.sqrt(n)
    if n < math.TOLERANCE then
        return { x = pt.x, y = pt.y }
    end
    return M.mul(pt, 1 / n)
end
function M.normalizeSelf(pt)
    local n = M.dot(pt, pt)
    if n == 1 then
        return pt
    end
    n = math.sqrt(n)
    if n < math.TOLERANCE then
        return pt
    end
    return M.mulSelf(pt, 1 / n)
end

-- 叉乘
function M.cross(pt1, pt2)
    return pt1.x * pt2.y - pt1.y * pt2.x
end

-- 点乘
function M.dot(pt1, pt2)
    return pt1.x * pt2.x + pt1.y * pt2.y
end

-- 1、点和原点的连线和x轴的夹角
-- 2、向量和x轴的夹角
function M.toAngleSelf(pt)
    return math.atan2(pt.y, pt.x)
end

-- 向量之间的夹角
function M.getAngle(pt1, pt2)
    local a2 = M.normalize(pt1)
    local b2 = M.normalize(pt2)
    local angle = math.atan2(M.cross(a2, b2), M.dot(a2, b2))
    if math.abs(angle) < math.FLT_EPSILON then
        return 0
    end

    return angle
end

-- 1、两点距离
-- 2、两个向量之差的长度
function M.getDistance(pt1, pt2)
    local x = pt1.x - pt2.x
    local y = pt1.y - pt2.y
    return math.sqrt(x * x + y * y)
end

function M.isLineIntersect(A, B, C, D, s, t)
    if ((A.x == B.x) and(A.y == B.y)) or((C.x == D.x) and(C.y == D.y)) then
        return false, s, t
    end

    local BAx = B.x - A.x
    local BAy = B.y - A.y
    local DCx = D.x - C.x
    local DCy = D.y - C.y
    local ACx = A.x - C.x
    local ACy = A.y - C.y

    local denom = DCy * BAx - DCx * BAy
    s = DCx * ACy - DCy * ACx
    t = BAx * ACy - BAy * ACx

    if (denom == 0) then
        if (s == 0 or t == 0) then
            return true, s, t
        end

        return false, s, t
    end

    s = s / denom
    t = t / denom

    return true, s, t
end

-- 正向垂直
function M.perp(pt)
    return { x = - pt.y, y = pt.x }
end
function M.perpSelf(pt)
    local x = pt.x
    pt.x = - pt.y
    pt.y = x
    return pt
end

-- 反向垂直
function M.rperp(pt)
    return { x = pt.y, y = - pt.x }
end
function M.rperpSelf(pt)
    local x = pt.x
    pt.x = pt.y
    pt.y = - x
    return pt
end

-- 对称
function M.negate(pt)
    return { x = - pt.x, y = - pt.y }
end 
function M.negateSelf(pt)
    pt.x = - pt.x
    pt.y = - pt.y
    return pt
end 

-- 向量pt1投影到pt2的向量
function M.project(pt1, pt2)
    local rate = M.dot(pt1, pt2) / M.dot(pt2, pt2)
    return { x = pt2.x * rate, y = pt2.y * rate }
end
function M.projectSelf(pt1, pt2)
    local rate = M.dot(pt1, pt2) / M.dot(pt2, pt2)
    pt1.x = pt2.x * rate
    pt1.y = pt2.y * rate
    return pt1
end 

-- 1、正向旋转，得出的向量角度是this.getAngle() + other.getAngle(), 长度是this.getLength() * other.getLength()，假如pt2是单位向量，那么几何意义就是向量pt1以pt2的角度的正向旋转
-- 2、复数乘法，等价于 pt1 * pt2
function M.rotate(pt1, pt2)
    return { x = pt1.x * pt2.x - pt1.y * pt2.y, y = pt1.x * pt2.y + pt1.y * pt2.x }
end
function M.rotateSelf(pt1, pt2)
    local x = pt1.x
    pt1.x = pt1.x * pt2.x - pt1.y * pt2.y
    pt1.y = x * pt2.y + pt1.y * pt2.x
    return pt1
end 

-- 1、反向旋转，得出的向量角度是this.getAngle() - other.getAngle(), 长度是this.getLength() * other.getLength()，假如pt2是单位向量，那么几何意义就是向量pt1以pt2的角度的反向旋转
-- 2、复数除法，等价于 pt1 / pt2 * |pt2|
function M.unrotate(pt1, pt2)
    return { x = pt1.x * pt2.x + pt1.y * pt2.y, pt1.y * pt2.x - pt1.x * pt2.y }
end
function M.unrotateSelf(pt1, pt2)
    local x = pt1.x
    pt1.x = pt1.x * pt2.x + pt1.y * pt2.y
    pt1.y = pt1.y * pt2.x - x * pt2.y
    return pt1
end

-- 1、点到原点的距离的平方
-- 2、向量长度的平方
function M.lengthSQ(pt)
    return M.dot(pt, pt)
end
-- 1、两点距离的平方
-- 2、两个向量之差的长度的平方
function M.distanceSQ(pt1, pt2)
    local x = pt1.x - pt2.x
    local y = pt1.y - pt2.y
    return x * x + y * y
end
-- 夹紧到由第二个和第三个指定的点所定义的范围内的第一个指定的点的值
function M.getClampPoint(pt1, pt2, pt3)
    return { x = math.clampf(pt1.x, pt2.x, pt3.x), y = math.clampf(pt1.y, pt2.y, pt3.y) }
end
function M.clampPoint(pt1, pt2, pt3)
    pt1.x = math.clampf(pt1.x, pt2.x, pt3.x)
    pt1.y = math.clampf(pt1.y, pt2.y, pt3.y)
    return pt1
end

-- 通过size构造vec2
function M.fromSize(sz)
    return { x = sz.width, y = sz.height }
end

-- 两点之间线性插入
function M.lerp(pt1, pt2, alpha)
    return { x = pt1.x *(1 - alpha) + pt2.x * alpha, y = pt1.y *(1 - alpha) + pt2.y * alpha }
end
function M.lerpSelf(pt1, pt2, alpha)
    pt1.x = pt1.x *(1 - alpha) + pt2.x * alpha
    pt1.y = pt1.y *(1 - alpha) + pt2.y * alpha
    return pt1
end

-- 两点相等比较
function M.equals(pt1, pt2)
    return (math.abs(pt1.x - pt2.x) < math.FLT_EPSILON) and (math.abs(pt1.y - pt2.y) < math.FLT_EPSILON)
end 

-- 两点进行模糊地相等比较
function M.fuzzyEqual(pt1, pt2, variance)
    if (pt1.x - variance <= pt2.x) and(pt2.x <= pt1.x + variance) and(pt1.y - variance <= pt2.y) and(pt2.y <= pt1.y + variance) then
        return true
    else
        return false
    end
end

-- pt1以pt2为圆心旋转angle
function M.rotateByAngle(pt1, pt2, angle)
    return M.addSelf(M.rotateSelf(M.sub(pt1, pt2), M.forAngle(angle)), pt2)
end
function M.rotateSelfByAngle(pt1, pt2, angle)
    return M.addSelf(M.rotateSelf(M.subSelf(pt1, pt2), M.forAngle(angle)), pt2)
end

function M.isSegmentIntersect(pt1, pt2, pt3, pt4)
    local s, t, ret = 0, 0, false
    ret, s, t = M.isLineIntersect(pt1, pt2, pt3, pt4, s, t)

    if ret and s >= 0 and s <= 1 and t >= 0 and t <= 1 then
        return true
    end

    return false
end

function M.getIntersectPoint(pt1, pt2, pt3, pt4)
    local s, t, ret = 0, 0, false
    ret, s, t = M.isLineIntersect(pt1, pt2, pt3, pt4, s, t)
    if ret then
        return { x = pt1.x + s *(pt2.x - pt1.x), y = pt1.y + s *(pt2.y - pt1.y) }
    else
        return { x = 0, y = 0 }
    end
end
