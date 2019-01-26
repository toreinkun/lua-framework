local math = math

local M = setglobal("vec4", { })

setmetatable(M, {
    __call = function(self, ...)
        return M.new(...)
    end
} )

function M.new(_x, _y, _z, _w)
    return { x = _x, y = _y, z = _z, w = _w }
end

function M.createFromAxisAngle(axis, angle)
    local halfAngle = angle * 0.5
    local sinHalfAngle = math.sin(halfAngle)

    local normal = vec3.new(axis.x, axis.y, axis.z)
    normal = vec3.normalize(normal)
    local dst = vec4.new(0, 0, 0, 0)
    dst.x = normal.x * sinHalfAngle
    dst.y = normal.y * sinHalfAngle
    dst.z = normal.z * sinHalfAngle
    dst.w = math.cos(halfAngle)

    return dst
end
