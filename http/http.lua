local M = setglobal("http", {})

local CURRENT_MODULE_NAME = ...

M.HttpRequestType = import(".HttpRequestType", CURRENT_MODULE_NAME)
M.HttpUtil = import(".HttpUtil", CURRENT_MODULE_NAME)

M.HttpRequest = import(".HttpRequest", CURRENT_MODULE_NAME)

return M

