local CURRENT_MODULE_NAME = ...

module("pool", package.seeall)

ObjectPoolManager = import(".ObjectPoolManager", CURRENT_MODULE_NAME)
ObjectPool = import(".ObjectPool", CURRENT_MODULE_NAME)
ObjectReusable = import(".ObjectReusable", CURRENT_MODULE_NAME)

_manager = ObjectPoolManager.new()
manager = function() 
    return _manager
end 

return nil