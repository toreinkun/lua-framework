local CURRENT_MODULE_NAME = ...

local buglyLog = buglyLog
local buglyReportLuaException = buglyReportLuaException

local LogType = import(".LogType", CURRENT_MODULE_NAME)

local M = class("LogBugly", import(".Logger", CURRENT_MODULE_NAME))

M._tag = "?"

function M:setLogTag(tag)
    self._tag = tag or "?"
end

function M:setUserId(userId)
    buglySetUserId(userId)
end 

function M:onLog(logType, msg, traceback)
    if traceback then
        if logType == LogType.Warning then 
            buglyReportLuaException(5, msg, traceback)
        else 
            buglyReportLuaException(6, msg, traceback)
        end 
    else 
        if DEBUG then 
            if string.find(msg, "%%") ~= nil then 
                error("there is percent sign in the log message")
                return
            end 
            buglyLog(logType, self._tag, msg)
        end 
    end
end

return M
