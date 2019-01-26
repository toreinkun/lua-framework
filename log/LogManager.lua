local CURRENT_MODULE_NAME = ...

local type = type
local table = table
local debug = debug
local os = os
local string = string
local assert = assert
local import = import

local LogType = import(".LogType", CURRENT_MODULE_NAME)

local M = class("LogManager")

local kDebugInfoLevel = 3

M._loggers = nil
M._userId = nil
M._logTag = nil

M._interceptLogType = LogType.Debug

M._printType = 0
M._printFileLine = false

local function _notifyAllLoggers(self, logType, msg, traceback)
    for _, logger in ipairs(self._loggers) do
        logger:onLog(logType, msg, traceback)
    end
end

local function _getPrintFile()
    local info = debug.getinfo(kDebugInfoLevel, "Sln")
    if not info then
        return ""
    end
    local source = info.source
    local func = info.name or info.what
    local line = info.currentline
    return string.format("\n[string \"%s\"]:%d in function %s", source or "?", line or 0, func or "?")
end

local function _logFormatMessage(self, logType, printType, ...)
    if self._interceptLogType > logType then
        return
    end
    if type(printType) == "number" then
        if printType > 0 and printType ~= self._printType and self._printType > 0 then return end
        if logType >= LogType.Warning then
            return _notifyAllLoggers(self, logType, string.format("[%d]%s", printType, string.format(...)), traceback(kDebugInfoLevel))
        elseif self._printFileLine then
            return _notifyAllLoggers(self, logType, string.format("[%d]%s%s", printType, string.format(...), _getPrintFile()))
        else
            return _notifyAllLoggers(self, logType, string.format("[%d]%s", printType, string.format(...)))
        end
    end
end 

local function _concatMessage(...)
    local args = {...}
    if not args[1] then 
        return ""
    end 
    for i,arg in ipairs(args) do 
        args[i] = tostring(arg)
    end 
    return  table.concat(args)
end 

local function _logConcatMessage(self, logType, printType, ...)
    if self._interceptLogType > logType then
        return
    end

    local args = { ...}
    if type(printType) == "number" then
        if printType > 0 and printType ~= self._printType and self._printType > 0 then return end
        if logType >= LogType.Warning then
            return _notifyAllLoggers(self, logType, string.format("[%d]%s", printType, _concatMessage(...)), traceback(kDebugInfoLevel))
        elseif self._printFileLine then
            return _notifyAllLoggers(self, logType, string.format("[%d]%s%s", printType, _concatMessage(...), _getPrintFile()))
        else
            return _notifyAllLoggers(self, logType, string.format("[%d]%s", printType, _concatMessage(...)))
        end
    end
end 

function M:ctor()
    self._loggers = { }
end

function M:setDebugged(debug)
    assert(type(debug) == "boolean", string.format("the parameter of debug:%s is boolean", tostring(debug)))
    if debug then
        self._interceptLogType = LogType.Debug
    else
        self._interceptLogType = LogType.Info
    end
end

function M:setPrintConfig(printType, printFileLine)
    assert(type(printType) == "number", string.format("the parameter of printType:%s is number", tostring(printType)))
    assert(type(printFileLine) == "boolean", string.format("the parameter of printFileLine:%s is boolean", tostring(printFileLine)))
    self._printType = printType
    self._printFileLine = printFileLine or false
end 

function M:setUserId(userId)
    assert(type(userId) == "string", string.format("the parameter of userId:%s is string", tostring(userId)))
    self._userId = userId
    for _, logger in ipairs(self._loggers) do
        logger:setUserId(userId)
    end
end 

function M:setLogTag(tag)
    assert(type(tag) == "string", string.format("the parameter of tag:%s is string", tostring(tag)))
    self._logTag = tag
    for _, logger in ipairs(self._loggers) do
        logger:setLogTag(tag)
    end
end 

function M:addLogger(logger)
    if self._logTag then
        logger:setLogTag(self._logTag)
    end
    if self._userId then
        logger:setUserId(self._userId)
    end
    return table.insert(self._loggers, logger)
end

function M:removeLogger(logger)
    return table.removebyvalue(self._loggers, logger)
end

function M:logDebug(...)
    return _logConcatMessage(self, LogType.Debug, ...)
end

function M:logDebugFormat(...)
    return _logFormatMessage(self, LogType.Debug, ...)
end

function M:logInfo(...)
    return _logConcatMessage(self, LogType.Info, ...)
end

function M:logInfoFormat(...)
    return _logFormatMessage(self, LogType.Info, ...)
end

function M:logWarn(...)
    return _logConcatMessage(self, LogType.Warning, ...)
end

function M:logWarnFormat(...)
    return _logFormatMessage(self, LogType.Warning, ...)
end

function M:logError(...)
    return _logConcatMessage(self, LogType.Error, ...)
end

function M:logErrorFormat(...)
    return _logFormatMessage(self, LogType.Error, ...)
end

function M:logOnlyDebug(...)
    return _logFormatMessage(self, LogType.OnlyDebug, ...)
end

return M