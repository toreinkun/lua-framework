local M = setglobal("c3b", { })

setmetatable(M, {
    __call = function(self, ...)
        return M.new(...)
    end
} )

function M.new( _r,_g,_b )
    return { r = _r, g = _g, b = _b }
end



function M.forHex(hex)
	assert(type(hex) == "number", string.format("the parameter of hex:%s is not number",tostring(hex)))
	local b = hex % 256
	hex = math.floor(hex / 256)
	local g = hex % 256
	local r = math.floor(hex / 256)
	return { r = r, g = g, b = b }
end 
