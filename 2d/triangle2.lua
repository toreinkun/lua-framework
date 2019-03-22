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
local vector2 = import(".vector2")

local M = module("triangle2")

setmetatable(
    M,
    {
        __call = function(self, ...)
            return M.new(...)
        end
    }
)

--[[
    --@a:[2d.vector2#M<>]
    --@b:[2d.vector2#M<>]
    --@c:[2d.vector2#M<>]
    @return:[2d.triangle2#M]
]]
function M.new(a, b, c)
    -- ab X ac == 0, parallel or collinear
    return {a = a, b = b, c = c}
end

function M.containsPoint(triangle, point)
end

function M.equals()
end

function M.clone()
end
