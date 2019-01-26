-- Size
local M = setglobal("size", { })

setmetatable(M, {__call = function(self, ...)
	return M.new(...)
end})

function M.new(_width, _height)
    return { width = _width, height = _height }
end

