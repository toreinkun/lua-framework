local M = class("ObjectPoolManager")

M._pools = nil

function M:ctor()
    self._pools = { }
end 

function M:getObject(T, ...)
    local pool = self._pools[T]
    if not pool then
        pool = ObjectPool.new(T)
        self._pools[T] = pool
    end
    return pool:getObject(...)
end 

function M:returnObject(obj)
    local pool = self._pools[obj.class]
    if not pool then
        return
    end
    return pool:returnObject(obj)
end 

return M