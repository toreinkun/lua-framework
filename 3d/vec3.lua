local M = setglobal("vec3", { })

setmetatable(M, {
    __call = function(self, ...)
        return M.new(...)
    end
} )

function M.new(_x, _y, _z)
    if nil == _y then
        return { x = _x.x, y = _x.y, z = _x.z }
    else
        return { x = _x, y = _y, z = _z }
    end
end

function M.add(pt1, pt2)
    return { x = pt1.x + pt2.x, y = pt1.y + pt2.y, z = pt1.z + pt2.z }
end
function M.addSelf(pt1, pt2)
    pt1.x = pt1.x + pt2.x
    pt1.y = pt1.y + pt2.y
    pt1.z = pt1.z + pt2.z
    return pt1
end 

function M.sub(pt1, pt2)
    return { x = pt1.x - pt2.x, y = pt1.y - pt2.y, z = pt1.z - pt2.z }
end
function M.subSelf(pt1, pt2)
    pt1.x = pt1.x - pt2.x
    pt1.y = pt1.y - pt2.y
    pt1.z = pt1.z - pt2.z
    return pt1
end

function M.mul(pt, factor)
    return { x = pt.x * factor, y = pt.y * factor, z = pt.z * factor }
end
function M.mulSelf(pt, factor)
    pt.x = pt.x * factor
    pt.y = pt.y * factor
    pt.z = pt.z * factor
    return pt
end

-- 点乘
function M.dot(pt1, pt2)
    return pt1.x * pt2.x + pt1.y * pt2.y + pt1.z * pt2.z
end

-- 标准化
function M.normalize(pt)
    local n = M.dot(pt, pt)
    if n == 1 then
        return {x = pt.x , y = pt.y , z = pt.z}
    end 
    n = math.sqrt(n)
    if n < math.TOLERANCE then
        return { x = pt.x, y = pt.y, z = pt.z }
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
    return { pt1.y * pt2.z - pt1.z * pt2.y, pt1.z * pt2.x - pt1.x * pt2.z, pt1.x * pt2.y - pt1.y * pt2.x }
end 
function M.crossSelf(pt1, pt2)
    local x = pt1.x
    local y = pt1.y
    pt1.x = y * pt2.z - pt1.z * pt2.y
    pt1.y = pt1.z * pt2.x - x * pt2.z
    pt1.z = x * pt2.y - y * pt2.x
    return pt1
end