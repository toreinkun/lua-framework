local M = setglobal("statist", {})

local CURRENT_MODULE_NAME = ...

local StatistAopUtil = import(".StatistAopUtil", CURRENT_MODULE_NAME)
local statistManager = import(".StatistManager", CURRENT_MODULE_NAME).new()

function M.init(typePath, configPath)
	statistManager:init(typePath, configPath)
end

function M.aop(aopPath)
	StatistAopUtil.init(statistManager, aopPath)
end

function M.log(id, ...)
	return statistManager:logEvent(id, ...)
end

return M

