local CURRENT_MODULE_NAME = ...

local M = setglobal("scheduler", {})

M.SchedulerTimer = import(".SchedulerTimer", CURRENT_MODULE_NAME)
M.SchedulerFrequency = import(".SchedulerFrequency", CURRENT_MODULE_NAME)

return M 