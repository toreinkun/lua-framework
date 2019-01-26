local math = math

-- Rect
local M = setglobal("rect", { })

setmetatable(M, {
    __call = function(self, ...)
        return M.new(...)
    end
} )

function M.new(_x, _y, _width, _height)
    return { x = _x, y = _y, width = _width, height = _height }
end

-- 
function M.equalToRect(rect1, rect2)
    return rect1.x == rect2.x and rect1.y == rect2.y and
    rect1.width == rect2.width and rect1.height == rect2.height
end

function M.getMaxX(rect)
    return rect.x + rect.width
end

function M.getMidX(rect)
    return rect.x + rect.width / 2.0
end

function M.getMinX(rect)
    return rect.x
end

function M.getMaxY(rect)
    return rect.y + rect.height
end

function M.getMidY(rect)
    return rect.y + rect.height / 2.0
end

function M.getMinY(rect)
    return rect.y
end

function M.containsPoint(rect, point)
    local ret = false

    if (point.x >= rect.x) and(point.x <= rect.x + rect.width) and
        (point.y >= rect.y) and(point.y <= rect.y + rect.height) then
        ret = true
    end

    return ret
end

function M.intersectsRect(rect1, rect2)
    local intersect = not(rect1.x > rect2.x + rect2.width or
    rect1.x + rect1.width < rect2.x or
    rect1.y > rect2.y + rect2.height or
    rect1.y + rect1.height < rect2.y)

    return intersect
end

function M.union(rect1, rect2)
    local rect = rect(0, 0, 0, 0)
    rect.x = math.min(rect1.x, rect2.x)
    rect.y = math.min(rect1.y, rect2.y)
    rect.width = math.max(rect1.x + rect1.width, rect2.x + rect2.width) - rect.x
    rect.height = math.max(rect1.y + rect1.height, rect2.y + rect2.height) - rect.y
    return rect
end

function M.intersection(rect1, rect2)
    local intersection = rect(
    math.max(rect1.x, rect2.x),
    math.max(rect1.y, rect2.y),
    0, 0)

    intersection.width = math.min(rect1.x + rect1.width, rect2.x + rect2.width) - intersection.x
    intersection.height = math.min(rect1.y + rect1.height, rect2.y + rect2.height) - intersection.y
    return intersection
end