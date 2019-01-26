local M = class("ObjectPool")

M._T = nil
M._pool = nil
M._count = 0

function M:ctor(T)
    self._T = T
    self._pool = { }
end 

function M:getObject(...)
    local obj = nil
    if self._count == 0 then
        obj = T.new()
        obj.__poolObj__ = self
    else
        obj = self._pool[self._count]
        self._count = self._count - 1
    end
    obj.__retainCount__ = 1
    obj:reuse(...)
    return obj
end 

function M:returnObject(obj)
    obj:recycle()
    self._count = self._count + 1
    self._pool[self._count] = obj
end

return M