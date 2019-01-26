local M = setglobal("c4f", { })

setmetatable(M, {
    __call = function(self, ...)
        return M.new(...)
    end
} )

function M.new( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end