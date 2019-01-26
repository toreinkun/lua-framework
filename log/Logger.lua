local M = class("Logger")

function M:setUserId(userId) end 

function M:setLogTag(tag) end

function M:onLog(logType, msg, traceback) end

return M