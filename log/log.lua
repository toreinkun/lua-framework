local M = setglobal("log", { })

local CURRENT_MODULE_NAME = ...

local LogManager = import(".LogManager", CURRENT_MODULE_NAME)
local LogBugly = import(".LogBugly", CURRENT_MODULE_NAME)

local _manager = LogManager.new()
_manager:addLogger(LogBugly.new())

function M.manager()
    return _manager
end    

function M.d(...)
    return _manager:logDebug(...)
end 

function M.dfmt(...)
    return _manager:logDebugFormat(...)
end

function M.i(...)
    return _manager:logInfo(...)
end 

function M.ifmt(...)
    return _manager:logInfoFormat(...)
end

function M.w(...)
    return _manager:logWarn(...)
end 

function M.wfmt(...)
    return _manager:logWarnFormat(...)
end

function M.e(...)
    return _manager:logError(...)
end 

function M.efmt(...)
    return _manager:logErrorFormat(...)
end

--onlyDebug
function M.o(...)
    return _manager:logOnlyDebug(...)
end

--服务器版本需要print
if not luajava then
    print = function ( ... ) end
end