local CURRENT_MODULE_NAME = ...

local import = import

local M = setglobal("ecs", {})

M.ECSComponent = import(".ECSComponent", CURRENT_MODULE_NAME)
M.ECSEngine = import(".ECSEngine", CURRENT_MODULE_NAME)
M.ECSEntity = import(".ECSEntity", CURRENT_MODULE_NAME)
M.ECSSystem = import(".ECSSystem", CURRENT_MODULE_NAME)
M.ECSEntityManager = import(".ECSEntityManager", CURRENT_MODULE_NAME)
M.ECSSystemManager = import(".ECSSystemManager", CURRENT_MODULE_NAME)

return M 