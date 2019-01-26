local M = class("ObjectReusable")

M.__retainCount__ = 0
M.__poolObj__ = nil

function M:retain()
    assert(self.__retainCount__ > 0, "the retain count has less than 0")
    self.__retainCount__ = self.__retainCount__ + 1
end 

function M:release()
    assert(self.__retainCount__ > 0, "the retain count has less than 0")
    self.__retainCount__ = self.__retainCount__ - 1
    if self.__retainCount__ == 0 then
        self.__poolObj__:returnObject(self)
    end
end 

function M:getRetainCount()
    return self.__retainCount__
end 

function M:reuse(...) end 

function M:recycle() end 

return M