-- 最大堆，大的数字上浮
-- 数据需要是数字，获取实现了>操作符
local M = class("MaxHeap", import(".Heap", ...))

local sort = function(a, b)
    return a > b
end

function M:ctor()
    M.super.ctor(self, sort)
end 

return M