local M = class("HttpCookie")

M._name = nil
M._value = nil
M._path = nil
M._domain = nil
M._expired = nil

function M:ctor(name,value,path,domain,expired)
    self._name = name
    self._value = value
    self._path = path
    self._domain = domain
    self._expired = expired
end

function M:tostring()

end 

return M